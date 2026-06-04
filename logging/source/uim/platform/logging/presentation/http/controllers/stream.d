/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.stream;
// import uim.platform.logging.application.usecases.manage.log_streams;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.log_stream;


import uim.platform.logging;

mixin(ShowModule!());

@safe:

class StreamController : ManageController {
  private ManageLogStreamsUseCase usecase;

  this(ManageLogStreamsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/streams", &handleCreate);
    router.get("/api/v1/streams", &handleList);
    router.get("/api/v1/streams/*", &handleGet);
    router.put("/api/v1/streams/*", &handleUpdate);
    router.delete_("/api/v1/streams/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
        CreateLogStreamRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.sourceType = data.getString("sourceType");
    r.retentionPolicyId = data.getString("retentionPolicyId");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createStream(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Log stream created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto streams = usecase.listStreams(tenantId);

    auto jarr = Json.emptyArray;
    foreach (s; streams) {
      jarr ~= Json.emptyObject
        .set("id", s.id)
        .set("name", s.name)
        .set("description", s.description)
        .set("isActive", s.isActive);
    }

    auto resp = Json.emptyObject
      .set("items", jarr)
      .set("totalCount", streams.length);

    return successResponse("Log stream list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = LogStreamId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid log stream ID", 400);

    auto s = usecase.getStream(tenantId, id);
    if (s.isNull) 
    return errorResponse("Log stream not found", 404);

    auto response = Json.emptyObject
      .set("id", s.id)
      .set("tenantId", s.tenantId)
      .set("name", s.name)
      .set("description", s.description)
      .set("isActive", s.isActive)
      .set("retentionPolicyId", s.retentionPolicyId);

    return successResponse("Log stream retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = LogStreamId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid log stream ID", 400);

    auto data = precheck.data;
    UpdateLogStreamRequest r;
    r.tenantId = tenantId;
    r.streamId = id;
    r.description = data.getString("description");
    r.retentionPolicyId = data.getString("retentionPolicyId");
    r.isActive = data.getBoolean("isActive", true);

    auto result = usecase.updateStream(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);
    return successResponse("Log stream updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = LogStreamId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid log stream ID", 400);

    auto result = usecase.deleteStream(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Log stream deleted successfully", "Deleted", 200, Json.emptyObject.set("id", id));
  }
}
