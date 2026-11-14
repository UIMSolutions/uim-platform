/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.import_queue_entries;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ManageImportQueueUseCase : IManageImportQueueUseCase {
  protected IImportQueueEntryRepository queue;
  protected ITransportNodeRepository nodes;
  protected ITransportRequestRepository requests;
  protected TransportActionRecorder recorder;
  protected ITransportEventPublisher publisher;

  this(IImportQueueEntryRepository queue, ITransportNodeRepository nodes, ITransportRequestRepository requests,
      TransportActionRecorder recorder, ITransportEventPublisher publisher) {
    this.queue = queue;
    this.nodes = nodes;
    this.requests = requests;
    this.recorder = recorder;
    this.publisher = publisher;
  }

  UsecaseResult enqueue(EnqueueInput input) {
    auto t = input.tenantId;
    auto entry = ImportQueueEntry(t);
    if (input.id.length > 0)
      entry.id = ImportQueueEntryId(input.id);
    entry.nodeId = TransportNodeId(input.nodeId);
    entry.requestId = TransportRequestId(input.requestId);

    auto invalid = TransportValidator.validateQueueEntry(entry);
    if (invalid.length > 0)
      return errorResult(400, "Invalid queue entry: " ~ invalid);
    if (queue.existsById(t, entry.id))
      return errorResult(409, "Queue entry '" ~ entry.id.value ~ "' already exists");

    auto node = nodes.findById(t, entry.nodeId);
    if (node.isNull)
      return notFoundResult("Transport node", entry.nodeId.value);
    auto request = requests.findById(t, entry.requestId);
    if (request.isNull)
      return notFoundResult("Transport request", entry.requestId.value);
    if (!queue.findPending(t, entry.nodeId, entry.requestId).isNull)
      return errorResult(409, "Request '" ~ request.name ~ "' is already waiting in the queue of '" ~ node.name ~ "'");

    auto now = Clock.currStdTime();
    entry.queuePosition = input.queuePosition > 0 ? input.queuePosition : queue.maxPosition(t, entry.nodeId) + 1;
    entry.isSelected = input.isSelected;
    entry.scheduledAt = input.scheduledAt;
    entry.queuedAt = now;
    entry.status = ImportStatus.initial;
    entry.createdBy = input.createdBy;
    queue.save(entry);

    if (request.queuedAt == 0) {
      request.queuedAt = now;
      requests.update(request);
    }
    syncRequestStatus(requests, queue, t, request.id);
    return okResult(entry.id.value, "Request '" ~ request.name ~ "' added to the import queue of '" ~ node.name ~ "'");
  }

  UsecaseResult selectEntry(TenantId tenantId, ImportQueueEntryId id, bool selected) {
    auto entry = queue.findById(tenantId, id);
    if (entry.isNull)
      return notFoundResult("Import queue entry", id.value);
    entry.isSelected = selected;
    entry.update();
    queue.update(entry);
    return okResult(id.value, selected ? "Entry selected for import" : "Entry deselected");
  }

  UsecaseResult updateEntryStatus(TenantId tenantId, ImportQueueEntryId id, ImportStatus status, string errorMessage = "") {
    auto entry = queue.findById(tenantId, id);
    if (entry.isNull)
      return notFoundResult("Import queue entry", id.value);
    auto now = Clock.currStdTime();
    if (status == ImportStatus.running)
      entry.start(now);
    else if (status == ImportStatus.initial || status == ImportStatus.repeating) {
      entry.reset(now);
      entry.status = status;
    } else
      entry.finish(status, now, entry.importLog, errorMessage);
    queue.update(entry);
    syncRequestStatus(requests, queue, tenantId, entry.requestId);
    return okResult(id.value, "Queue entry set to " ~ enumName(status));
  }

  UsecaseResult resetEntry(TenantId tenantId, ImportQueueEntryId id, string performedBy = "") {
    auto entry = queue.findById(tenantId, id);
    if (entry.isNull)
      return notFoundResult("Import queue entry", id.value);
    if (entry.status == ImportStatus.running)
      return errorResult(422, "Queue entry is being imported");
    if (entry.isPending)
      return okResult(id.value, "Queue entry is already waiting for import");

    entry.reset(Clock.currStdTime());
    queue.update(entry);
    syncRequestStatus(requests, queue, tenantId, entry.requestId);
    recorder.record(tenantId, ActionType.reset, ActionStatus.success, entry.nodeId, entry.requestId,
      performedBy, "Reset queue entry for another import");
    publisher.publish(TransportTopics.queueEntryReset, entry.toJson);
    return okResult(id.value, "Queue entry reset — it will be imported again");
  }

  UsecaseResult deleteEntry(TenantId tenantId, ImportQueueEntryId id, string performedBy = "") {
    auto entry = queue.findById(tenantId, id);
    if (entry.isNull)
      return notFoundResult("Import queue entry", id.value);
    if (entry.status == ImportStatus.running)
      return errorResult(422, "Queue entry is being imported");
    queue.remove(entry);
    syncRequestStatus(requests, queue, tenantId, entry.requestId);
    recorder.record(tenantId, ActionType.delete_, ActionStatus.success, entry.nodeId, entry.requestId,
      performedBy, "Removed request from the import queue");
    return okResult(id.value, "Queue entry removed");
  }

  bool hasEntry(TenantId tenantId, ImportQueueEntryId id) {
    return queue.existsById(tenantId, id);
  }

  ImportQueueEntry getEntry(TenantId tenantId, ImportQueueEntryId id) {
    return queue.findById(tenantId, id);
  }

  ImportQueueEntry[] listEntries(TenantId tenantId) {
    return queue.findByTenant(tenantId).sort!((a, b) => a.queuedAt > b.queuedAt).array;
  }

  ImportQueueEntry[] listEntriesByNode(TenantId tenantId, TransportNodeId nodeId) {
    return queue.findByNode(tenantId, nodeId).sort!((a, b) => a.queuePosition < b.queuePosition).array;
  }

  ImportQueueEntry[] listEntriesByNodeAndStatus(TenantId tenantId, TransportNodeId nodeId, ImportStatus status) {
    return queue.findByNodeAndStatus(tenantId, nodeId, status);
  }

  ImportQueueEntry[] listEntriesByRequest(TenantId tenantId, TransportRequestId requestId) {
    return queue.findByRequest(tenantId, requestId);
  }
}
