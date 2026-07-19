/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.replication_task;
// import uim.platform.hana.application.usecases.manage.replication_tasks;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class ReplicationTaskController : ManageHttpController {
  private ManageReplicationTasksUseCase usecase;

  this(ManageReplicationTasksUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/hana/replicationTasks", &handleList);
    router.get("/api/v1/hana/replicationTasks/*", &handleGet);
    router.post("/api/v1/hana/replicationTasks", &handleCreate);
    router.put("/api/v1/hana/replicationTasks/*", &handleUpdate);
    router.delete_("/api/v1/hana/replicationTasks/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateReplicationTaskRequest r;
    r.tenantId = tenantId;
    r.instanceId = data.getString("instanceId");
    r.id = precheck.id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.mode = data.getString("mode");
    r.sourceConnectionId = data.getString("sourceConnectionId");
    r.targetConnectionId = data.getString("targetConnectionId");
    r.scheduleExpression = data.getString("scheduleExpression");
    r.mappings = jsonKeyValuePairs(j, "mappings");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Replication task created successfully", 201, resp);
}

override protected Json listHandler(HTTPServerRequest req) {
  auto precheck = super.listHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto tasks = usecase.list(tenantId);

  auto jarr = Json.emptyArray;
  foreach (t; tasks) {
    jarr ~= Json.emptyObject
      .set("id", t.id)
      .set("instanceId", t.instanceId)
      .set("name", t.name)
      .set("mode", t.mode.to!string)
      .set("status", t.status.to!string)
      .set("rowsReplicated", t.rowsReplicated)
      .set("createdAt", t.createdAt);
  }

  auto response = Json.emptyObject
    .set("count", tasks.length)
    .set("resources", jarr);
  return successResponse("Replication task list retrieved successfully", "Retrieved", 200, response);
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = precheck.id;
  auto t = usecase.getById(tenantId, id);
  if (t.isNull)
    return errorResponse("Replication task not found", 404);

  auto resp = Json.emptyObject
    .set("id", t.id)
    .set("instanceId", t.instanceId)
    .set("name", t.name)
    .set("description", t.description)
    .set("mode", t.mode.to!string)
    .set("status", t.status.to!string)
    .set("sourceConnectionId", t.sourceConnectionId)
    .set("targetConnectionId", t.targetConnectionId)
    .set("scheduleExpression", t.scheduleExpression)
    .set("rowsReplicated", t.rowsReplicated)
    .set("errorCount", t.errorCount)
    .set("lastRunAt", t.lastRunAt)
    .set("nextRunAt", t.nextRunAt)
    .set("createdAt", t.createdAt)
    .set("updatedAt", t.updatedAt);

  return successResponse("Replication task retrieved successfully", "Retrieved", 200, resp);
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  auto data = precheck.data;
  UpdateReplicationTaskRequest r;
  r.tenantId = tenantId;
  r.id = precheck.id;
  r.name = data.getString("name");
  r.description = data.getString("description");
  r.mode = data.getString("mode");
  r.scheduleExpression = data.getString("scheduleExpression");

  auto result = usecase.update(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Replication task updated successfully", "Updated", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = ReplicationTaskId(precheck.id);
  auto result = usecase.deleteReplicationTask(id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Replication task deleted successfully", "Deleted", 200, responseData);
}
}
