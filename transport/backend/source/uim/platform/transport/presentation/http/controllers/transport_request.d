/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.http.controllers.transport_request;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// REST: /api/v1/transport/requests
///   PUT {"action": "export", "nodeId"?}  export along the routes
///   PUT {"action": "forward", "fromNodeId"} forward to the follow-on nodes
///   PUT {"status": "..."} set the status manually; other fields update the request
class TransportRequestController : ManageHttpController {
  protected IManageTransportRequestsUseCase requests;
  protected ITransportOperationsUseCase operations;

  this(IManageTransportRequestsUseCase requests, ITransportOperationsUseCase operations) {
    this.requests = requests;
    this.operations = operations;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get(restBase ~ "/requests", &handleList);
    router.get(restBase ~ "/requests/*", &handleGet);
    router.post(restBase ~ "/requests", &handleCreate);
    router.put(restBase ~ "/requests/*", &handleUpdate);
    router.delete_(restBase ~ "/requests/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;
    return successResponse("Transport requests retrieved", "Retrieved", 200, listPayload(requests.listRequests(precheck.tenantId)));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;
    auto request = requests.getRequest(precheck.tenantId, TransportRequestId(precheck.id));
    if (request.isNull)
      return errorResponse("Transport request not found", 404);
    return successResponse("Transport request retrieved", "Retrieved", 200, request.toJson);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;
    auto data = precheck.data;
    CreateRequestInput input;
    input.tenantId = precheck.tenantId;
    input.id = data.getString("id");
    input.name = data.getString("name");
    input.description = data.getString("description");
    input.externalId = data.getString("externalId");
    input.contentType = data.getString("contentType");
    input.version_ = data.getString("version");
    input.contentSize = data.getString("contentSize");
    input.storageUrl = data.getString("storageUrl");
    input.checksum = data.getString("checksum");
    input.sourceNodeId = data.getString("sourceNodeId");
    input.namedUser = data.getString("namedUser");
    input.systemId = data.getString("systemId");
    input.createdBy = UserId(data.getString("createdBy"));
    auto created = requests.createRequest(input);
    if (created.isSuccess && pickBool(data, "export", false)) {
      ExportInput ex;
      ex.tenantId = input.tenantId;
      ex.requestId = TransportRequestId(created.id);
      ex.performedBy = input.createdBy.value;
      auto exported = operations.exportRequest(ex);
      if (!exported.isSuccess)
        return errorResponse("Request created (" ~ created.id ~ ") but export failed: " ~ exported.message,
          cast(int) exported.code);
      created.message ~= "; " ~ exported.message;
    }
    return usecaseResponse(created, "Created", 201);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenant = precheck.tenantId;
    auto id = TransportRequestId(precheck.id);
    auto data = precheck.data;
    auto by = data.getString("performedBy");

    switch (data.getString("action")) {
    case "export": {
      ExportInput ex;
      ex.tenantId = tenant;
      ex.requestId = id;
      ex.nodeId = TransportNodeId(data.getString("nodeId"));
      ex.performedBy = by;
      return usecaseResponse(operations.exportRequest(ex), "Exported");
    }
    case "forward": {
      ForwardInput fw;
      fw.tenantId = tenant;
      fw.requestId = id;
      fw.fromNodeId = TransportNodeId(data.getString("fromNodeId"));
      fw.performedBy = by;
      return usecaseResponse(operations.forwardRequest(fw), "Forwarded");
    }
    default: {
      break;
    }
    }

    auto statusText = data.getString("status");
    if (statusText.length > 0) {
      RequestStatus status;
      if (!tryParseEnum!RequestStatus(statusText, status))
        return errorResponse("Invalid status '" ~ statusText ~ "'", 400);
      return usecaseResponse(requests.updateRequestStatus(tenant, id, status), "Updated");
    }

    auto current = requests.getRequest(tenant, id);
    if (current.isNull)
      return errorResponse("Transport request not found", 404);
    auto input = UpdateRequestInput.from(current);
    input.name = pick(data, "name", input.name);
    input.description = pick(data, "description", input.description);
    input.externalId = pick(data, "externalId", input.externalId);
    input.contentType = pick(data, "contentType", input.contentType);
    input.version_ = pick(data, "version", input.version_);
    input.contentSize = pick(data, "contentSize", input.contentSize);
    input.storageUrl = pick(data, "storageUrl", input.storageUrl);
    input.checksum = pick(data, "checksum", input.checksum);
    input.namedUser = pick(data, "namedUser", input.namedUser);
    input.systemId = pick(data, "systemId", input.systemId);
    input.updatedBy = UserId(data.getString("updatedBy"));
    return usecaseResponse(requests.updateRequest(input), "Updated");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;
    return usecaseResponse(requests.deleteRequest(precheck.tenantId, TransportRequestId(precheck.id)), "Deleted");
  }
}
