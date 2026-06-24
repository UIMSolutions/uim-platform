/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.remote_table;
// import uim.platform.datasphere.application.usecases.manage.remote_tables;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

// mixin(ShowModule!());

@safe:

class RemoteTableController : ManageHttpController {
  private ManageRemoteTablesUseCase usecase;

  this(ManageRemoteTablesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/remoteTables", &handleList);
    router.get("/api/v1/datasphere/remoteTables/*", &handleGet);
    router.post("/api/v1/datasphere/remoteTables", &handleCreate);
    router.delete_("/api/v1/datasphere/remoteTables/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateRemoteTableRequest r;
    r.tenantId = tenantId;
    r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    r.connectionId = ConnectionId(data.getString("connectionId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.remoteSchema = data.getString("remoteSchema");
    r.remoteObjectName = data.getString("remoteObjectName");
    r.replicationMode = data.getString("replicationMode");

    auto result = usecase.createRemoteTable(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Remote table created successfully", 200, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto tables = usecase.listRemoteTables(tenantId, spaceId);
    auto list = Json.emptyArray;
    foreach (rt; tables) {
      list ~= Json.emptyObject
        .set("id", rt.id)
        .set("name", rt.name)
        .set("description", rt.description)
        .set("connectionId", rt.connectionId)
        .set("remoteSchema", rt.remoteSchema)
        .set("remoteObjectName", rt.remoteObjectName)
        .set("rowCount", rt.rowCount)
        .set("lastReplicatedAt", rt.lastReplicatedAt)
        .set("createdAt", rt.createdAt);
    }

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Remote tables retrieved successfully", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RemoteTableId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid remote table ID", 400);

    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto rt = usecase.getRemoteTableById(tenantId, spaceId, id);
    if (rt.isNull)
      return errorResponse("Remote table not found", 404);

    auto resp = Json.emptyObject
      .set("id", rt.id)
      .set("name", rt.name)
      .set("description", rt.description)
      .set("connectionId", rt.connectionId)
      .set("remoteSchema", rt.remoteSchema)
      .set("remoteObjectName", rt.remoteObjectName)
      .set("rowCount", rt.rowCount)
      .set("lastReplicatedAt", rt.lastReplicatedAt)
      .set("createdAt", rt.createdAt)
      .set("updatedAt", rt.updatedAt);

    return successResponse("Remote table retrieved successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RemoteTableId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid remote table ID", 400);

    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto result = usecase.deleteRemoteTable(tenantId, spaceId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Remote table deleted successfully", 204, Json.emptyObject);
  }
}
