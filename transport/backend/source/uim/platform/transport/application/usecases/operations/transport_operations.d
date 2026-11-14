/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The transport workflow of SAP Cloud Transport Management:
///
///   export   request ──► import queues of the follow-on nodes of its source node
///   import   queue entry ──► IDeploymentGateway.deploy ──► success | warning | failed
///   forward  (automatic after a successful import if the node forwards) ──► next queues
///
/// Every step is recorded in the audit trail (TransportAction) and the aggregated
/// request status is kept in sync with its queue entries.
module uim.platform.transport.application.usecases.operations.transport_operations;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportOperationsUseCase : ITransportOperationsUseCase {
  protected ITransportNodeRepository nodes;
  protected ITransportRouteRepository routes;
  protected ITransportRequestRepository requests;
  protected IImportQueueEntryRepository queue;
  protected TransportActionRecorder recorder;
  protected IDeploymentGateway gateway;
  protected ITransportEventPublisher publisher;

  this(ITransportNodeRepository nodes, ITransportRouteRepository routes, ITransportRequestRepository requests,
      IImportQueueEntryRepository queue, TransportActionRecorder recorder, IDeploymentGateway gateway,
      ITransportEventPublisher publisher) {
    this.nodes = nodes;
    this.routes = routes;
    this.requests = requests;
    this.queue = queue;
    this.recorder = recorder;
    this.gateway = gateway;
    this.publisher = publisher;
  }

  // ── export ─────────────────────────────────────────────────────────────

  UsecaseResult exportRequest(ExportInput input) {
    auto t = input.tenantId;
    auto request = requests.findById(t, input.requestId);
    if (request.isNull)
      return notFoundResult("Transport request", input.requestId.value);

    auto sourceId = input.nodeId.isEmpty ? request.sourceNodeId : input.nodeId;
    if (sourceId.isEmpty)
      return errorResult(422, "Transport request '" ~ request.name ~ "' has no source node — pass the export node");
    auto source = nodes.findById(t, sourceId);
    if (source.isNull)
      return notFoundResult("Transport node", sourceId.value);
    if (!source.isEnabled)
      return errorResult(422, "Transport node '" ~ source.name ~ "' is disabled");

    auto landscape = landscapeOf(t);
    auto outgoing = landscape.outgoing(sourceId);
    if (outgoing.length == 0)
      return errorResult(422, "No enabled route leaves node '" ~ source.name ~ "'");

    if (request.sourceNodeId.isEmpty) {
      request.sourceNodeId = sourceId;
      request.update();
      requests.update(request);
    }

    auto targets = distribute(t, request, source, outgoing, landscape, ActionType.export_, input.performedBy);
    syncRequestStatus(requests, queue, t, request.id);

    auto names = Json.emptyArray;
    foreach (n; targets)
      names ~= Json(n);
    publisher.publish(TransportTopics.requestExported, Json.emptyObject
        .set("tenantId", t.value).set("requestId", request.id.value)
        .set("sourceNodeId", sourceId.value).set("destinations", names));
    return okResult(request.id.value, "Request '%s' exported from '%s' to %d node(s)%s"
        .format(request.name, source.name, targets.length, targets.length ? ": " ~ targets.join(", ") : ""),
      Json.emptyObject.set("destinations", names));
  }

  // ── import ─────────────────────────────────────────────────────────────

  UsecaseResult importNode(ImportInput input) {
    auto t = input.tenantId;
    auto node = nodes.findById(t, input.nodeId);
    if (node.isNull)
      return notFoundResult("Transport node", input.nodeId.value);
    if (!node.isEnabled)
      return errorResult(422, "Transport node '" ~ node.name ~ "' is disabled");

    ImportQueueEntry[] entries;
    if (input.entryIds.length > 0) {
      foreach (id; input.entryIds) {
        auto e = queue.findById(t, id);
        if (e.isNull)
          return notFoundResult("Import queue entry", id.value);
        if (e.nodeId != node.id)
          return errorResult(422, "Queue entry '" ~ id.value ~ "' does not belong to node '" ~ node.name ~ "'");
        if (!e.isPending)
          return errorResult(422, "Queue entry '" ~ id.value ~ "' is not waiting for import (status "
              ~ enumName(e.status) ~ ") — reset it first");
        entries ~= e;
      }
    } else {
      entries = queue.findByNode(t, node.id).filter!(e => e.isImportable).array;
    }
    entries.sort!((a, b) => a.queuePosition < b.queuePosition);

    ImportRunSummary summary;
    summary.nodeId = node.id;
    if (entries.length == 0)
      return okResult(node.id.value, "Nothing to import in the queue of '" ~ node.name ~ "'", summary.toJson);

    auto landscape = landscapeOf(t);
    foreach (entry; entries) {
      summary.imported++;
      summary.entryIds ~= entry.id.value;
      auto request = requests.findById(t, entry.requestId);

      entry.start(Clock.currStdTime());
      queue.update(entry);

      DeploymentResult result;
      if (request.isNull)
        result = DeploymentResult.fail("", "Transport request '" ~ entry.requestId.value ~ "' no longer exists");
      else {
        try
          result = gateway.deploy(node, request);
        catch (Exception e)
          result = DeploymentResult.fail("", "Deployment failed: " ~ e.msg);
      }

      auto now = Clock.currStdTime();
      entry.finish(result.status, now, result.log, result.error);
      queue.update(entry);

      final switch (result.status) with (ImportStatus) {
      case success:
        summary.succeeded++;
        break;
      case warning:
        summary.warnings++;
        break;
      case failed:
      case initial:
      case running:
      case repeating:
        summary.failed++;
        break;
      }

      recorder.record(t, ActionType.import_, toActionStatus(result.status), node.id, entry.requestId,
        input.performedBy, "Import of '" ~ (request.isNull ? entry.requestId.value : request.name)
          ~ "' into '" ~ node.name ~ "'", result.log, result.error);

      if (request.isNull)
        continue;

      if (result.status == ImportStatus.failed) {
        request.errorMessage = result.error;
      } else {
        request.importedAt = now;
        request.errorMessage = "";
      }
      request.updatedAt = now;
      requests.update(request);

      if (result.status != ImportStatus.failed && node.isForwardEnabled) {
        auto forwardedTo = distribute(t, request, node, landscape.outgoing(node.id), landscape,
          ActionType.forward, input.performedBy);
        summary.forwarded += forwardedTo.length;
      }
      syncRequestStatus(requests, queue, t, request.id);
    }

    publisher.publish(TransportTopics.importFinished, summary.toJson.set("tenantId", t.value));
    auto message = "Imported %d request(s) into '%s': %d succeeded, %d with warnings, %d failed"
      .format(summary.imported, node.name, summary.succeeded, summary.warnings, summary.failed);
    if (summary.forwarded > 0)
      message ~= ", %d forwarded".format(summary.forwarded);
    return okResult(node.id.value, message, summary.toJson);
  }

  // ── forward ────────────────────────────────────────────────────────────

  UsecaseResult forwardRequest(ForwardInput input) {
    auto t = input.tenantId;
    auto request = requests.findById(t, input.requestId);
    if (request.isNull)
      return notFoundResult("Transport request", input.requestId.value);
    auto from = nodes.findById(t, input.fromNodeId);
    if (from.isNull)
      return notFoundResult("Transport node", input.fromNodeId.value);

    auto landscape = landscapeOf(t);
    auto outgoing = landscape.outgoing(from.id);
    if (outgoing.length == 0)
      return errorResult(422, "No enabled route leaves node '" ~ from.name ~ "'");

    auto targets = distribute(t, request, from, outgoing, landscape, ActionType.forward, input.performedBy);
    syncRequestStatus(requests, queue, t, request.id);
    publisher.publish(TransportTopics.requestForwarded, Json.emptyObject
        .set("tenantId", t.value).set("requestId", request.id.value).set("fromNodeId", from.id.value));
    if (targets.length == 0)
      return okResult(request.id.value, "Request '" ~ request.name ~ "' is already waiting in all follow-on queues");
    return okResult(request.id.value, "Request '%s' forwarded from '%s' to %s"
        .format(request.name, from.name, targets.join(", ")));
  }

  // ── connectivity ───────────────────────────────────────────────────────

  UsecaseResult checkConnection(TenantId tenantId, TransportNodeId nodeId) {
    auto node = nodes.findById(tenantId, nodeId);
    if (node.isNull)
      return notFoundResult("Transport node", nodeId.value);
    bool reachable;
    try
      reachable = gateway.ping(node);
    catch (Exception)
      reachable = false;
    node.connectionStatus = reachable ? "connected" : "unreachable";
    node.lastCheckedAt = Clock.currStdTime();
    nodes.update(node);
    return okResult(node.id.value, "Transport node '" ~ node.name ~ "' is " ~ (reachable ? "reachable" : "NOT reachable"),
      Json.emptyObject.set("connectionStatus", node.connectionStatus).set("reachable", reachable));
  }

  // ── helpers ────────────────────────────────────────────────────────────

  protected TransportLandscape landscapeOf(TenantId t) {
    return TransportLandscape(nodes.findByTenant(t), routes.findByTenant(t));
  }

  /// Put the request into the queues of the destinations of the given routes.
  /// Returns the names of the nodes where it was added (duplicates are skipped).
  protected string[] distribute(TenantId t, const TransportRequest request, const TransportNode from,
      const TransportRoute[] outgoing, const TransportLandscape landscape, ActionType type, string performedBy) {
    string[] added;
    foreach (route; outgoing) {
      auto destination = landscape.node(route.destinationNodeId);
      if (!queue.findPending(t, destination.id, request.id).isNull)
        continue;

      auto entry = ImportQueueEntry(t);
      entry.nodeId = destination.id;
      entry.requestId = request.id;
      entry.queuePosition = queue.maxPosition(t, destination.id) + 1;
      entry.queuedAt = Clock.currStdTime();
      entry.createdBy = UserId(actor(performedBy));
      queue.save(entry);
      added ~= destination.name;

      recorder.record(t, type, ActionStatus.success, destination.id, request.id, performedBy,
        (type == ActionType.export_ ? "Exported" : "Forwarded") ~ " '" ~ request.name ~ "' from '"
          ~ from.name ~ "' to '" ~ destination.name ~ "' via route '" ~ route.name ~ "'",
        "", "", route.id);
    }
    return added;
  }
}
