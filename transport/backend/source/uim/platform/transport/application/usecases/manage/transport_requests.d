/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.usecases.manage.transport_requests;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class ManageTransportRequestsUseCase : IManageTransportRequestsUseCase {
  protected ITransportRequestRepository requests;
  protected ITransportNodeRepository nodes;
  protected IImportQueueEntryRepository queue;
  protected TransportActionRecorder recorder;
  protected ITransportEventPublisher publisher;

  this(ITransportRequestRepository requests, ITransportNodeRepository nodes, IImportQueueEntryRepository queue,
      TransportActionRecorder recorder, ITransportEventPublisher publisher) {
    this.requests = requests;
    this.nodes = nodes;
    this.queue = queue;
    this.recorder = recorder;
    this.publisher = publisher;
  }

  UsecaseResult createRequest(CreateRequestInput input) {
    auto t = input.tenantId;
    auto request = TransportRequest(t);
    if (input.id.length > 0)
      request.id = TransportRequestId(input.id);
    if (requests.existsById(t, request.id))
      return errorResult(409, "Transport request '" ~ request.id.value ~ "' already exists");

    ContentType type = ContentType.mtaArchive;
    if (input.contentType.length > 0 && !tryParseEnum!ContentType(input.contentType, type))
      return errorResult(400, "Invalid contentType '" ~ input.contentType ~ "' (" ~ enumNames!ContentType.join(", ") ~ ")");

    request.name = input.name.strip;
    request.description = input.description;
    request.externalId = input.externalId;
    request.contentType = type;
    request.version_ = input.version_;
    request.contentSize = input.contentSize;
    request.storageUrl = input.storageUrl;
    request.checksum = input.checksum;
    request.sourceNodeId = TransportNodeId(input.sourceNodeId);
    request.namedUser = input.namedUser.length > 0 ? input.namedUser : input.createdBy.value;
    request.systemId = input.systemId;
    request.status = RequestStatus.initial;
    request.createdBy = input.createdBy;
    request.updatedBy = input.createdBy;

    auto invalid = TransportValidator.validateRequest(request);
    if (invalid.length > 0)
      return errorResult(400, "Invalid transport request: " ~ invalid);
    if (!request.sourceNodeId.isEmpty && !nodes.existsById(t, request.sourceNodeId))
      return notFoundResult("Source node", request.sourceNodeId.value);

    requests.save(request);
    publisher.publish(TransportTopics.requestCreated, request.toJson);
    return okResult(request.id.value, "Transport request '" ~ request.name ~ "' created");
  }

  UsecaseResult updateRequest(UpdateRequestInput input) {
    auto request = requests.findById(input.tenantId, input.requestId);
    if (request.isNull)
      return notFoundResult("Transport request", input.requestId.value);

    ContentType type = request.contentType;
    if (input.contentType.length > 0 && !tryParseEnum!ContentType(input.contentType, type))
      return errorResult(400, "Invalid contentType '" ~ input.contentType ~ "'");

    if (input.name.strip.length > 0)
      request.name = input.name.strip;
    request.description = input.description;
    request.externalId = input.externalId;
    request.contentType = type;
    request.version_ = input.version_;
    request.contentSize = input.contentSize;
    request.storageUrl = input.storageUrl;
    request.checksum = input.checksum;
    request.namedUser = input.namedUser;
    request.systemId = input.systemId;
    request.update(input.updatedBy);
    requests.update(request);
    return okResult(request.id.value, "Transport request '" ~ request.name ~ "' updated");
  }

  UsecaseResult updateRequestStatus(TenantId tenantId, TransportRequestId id, RequestStatus status) {
    auto request = requests.findById(tenantId, id);
    if (request.isNull)
      return notFoundResult("Transport request", id.value);
    request.status = status;
    request.update();
    requests.update(request);
    return okResult(id.value, "Transport request '" ~ request.name ~ "' set to " ~ enumName(status));
  }

  UsecaseResult deleteRequest(TenantId tenantId, TransportRequestId id, string performedBy = "") {
    auto request = requests.findById(tenantId, id);
    if (request.isNull)
      return notFoundResult("Transport request", id.value);
    auto entries = queue.findByRequest(tenantId, id);
    if (entries.any!(e => e.status == ImportStatus.running))
      return errorResult(422, "Transport request '" ~ request.name ~ "' is being imported");

    queue.remove(entries);
    requests.remove(request);
    recorder.record(tenantId, ActionType.delete_, ActionStatus.success, TransportNodeId.init, id,
      performedBy, "Deleted transport request '" ~ request.name ~ "' and %d queue entr%s"
        .format(entries.length, entries.length == 1 ? "y" : "ies"));
    return okResult(id.value, "Transport request '" ~ request.name ~ "' deleted");
  }

  bool hasRequest(TenantId tenantId, TransportRequestId id) {
    return requests.existsById(tenantId, id);
  }

  TransportRequest getRequest(TenantId tenantId, TransportRequestId id) {
    return requests.findById(tenantId, id);
  }

  TransportRequest[] listRequests(TenantId tenantId) {
    return requests.findByTenant(tenantId).sort!((a, b) => a.createdAt > b.createdAt).array;
  }

  TransportRequest[] listRequestsByStatus(TenantId tenantId, RequestStatus status) {
    return requests.findByStatus(tenantId, status);
  }

  TransportRequest[] listRequestsByNode(TenantId tenantId, TransportNodeId nodeId) {
    return requests.findBySourceNode(tenantId, nodeId);
  }
}
