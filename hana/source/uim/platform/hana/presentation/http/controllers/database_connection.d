/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.database_connection;
// import uim.platform.hana.application.usecases.manage.database_connections;
// import uim.platform.hana.application.dto;
import uim.platform.hana;
mixin(ShowModule!());

@safe:

class DatabaseConnectionController : ManageHttpController {
  private ManageDatabaseConnectionsUseCase usecase;

  this(ManageDatabaseConnectionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/connections", &handleList);
    router.get("/api/v1/hana/connections/*", &handleGet);
    router.post("/api/v1/hana/connections", &handleCreate);
    router.put("/api/v1/hana/connections/*", &handleUpdate);
    router.delete_("/api/v1/hana/connections/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDatabaseConnectionRequest r;
    r.tenantId = tenantId;
    r.instanceId = data.getString("instanceId");
    r.id = DatabaseConnectionId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.type = data.getString("type");
    r.host = data.getString("host");
    r.port = data.getInteger("port", 443);
    r.database = data.getString("database");
    r.user = data.getString("user");
    r.password = data.getString("password");
    r.useTls = data.getBoolean("useTls", true);
    r.minConnections = data.getInteger("minConnections", 1);
    r.maxConnections = data.getInteger("maxConnections", 10);
    r.properties = jsonKeyValuePairs(j, "properties");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    
return successResponse("Database connection created successfully", 201, resp);
}

override protected Json listHandler(HTTPServerRequest req) {
  auto precheck = super.listHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto conns = usecase.list(tenantId);

  auto jarr = Json.emptyArray;
  foreach (c; conns) {
    jarr ~= Json.emptyObject
      .set("id", c.id)
      .set("instanceId", c.instanceId)
      .set("name", c.name)
      .set("type", c.type.to!string)
      .set("status", c.status.to!string)
      .set("host", c.host)
      .set("port", c.port)
      .set("createdAt", c.createdAt);
  }

  auto resp = Json.emptyObject
    .set("count", Json(conns.length))
    .set("resources", jarr);

  return successResponse("Database connection list retrieved successfully", 200, resp);
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = DatabaseConnectionId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid database connection ID", 400);

  auto c = usecase.getById(tenantId, id);
  if (c.isNull)
    return errorResponse("Database connection not found", 404);

  auto resp = Json.emptyObject
    .set("id", c.id)
    .set("instanceId", c.instanceId)
    .set("name", c.name)
    .set("description", c.description)
    .set("type", c.type.to!string)
    .set("status", c.status.to!string)
    .set("host", c.host)
    .set("port", c.port)
    .set("database", c.database)
    .set("user", c.user)
    .set("useTls", c.useTls)
    .set("createdAt", c.createdAt)
    .set("updatedAt", c.updatedAt);

  return successResponse("Database connection retrieved successfully", "Retrieved", 200, resp);
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = DatabaseConnectionId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid database connection ID", 400);

  auto data = precheck.data;
  UpdateDatabaseConnectionRequest r;
  r.tenantId = tenantId;
  r.connectionId = id;
  r.type = data.getString("type");
  r.name = data.getString("name");
  r.description = data.getString("description");
  r.host = data.getString("host");
  r.port = data.getInteger("port", 443);
  r.database = data.getString("database");
  r.user = data.getString("user");
  r.password = data.getString("password");

  auto result = usecase.update(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto resp = Json.emptyObject.set("id", result.id);
  return successResponse("Database connection updated successfully", "Updated", 200, resp);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = DatabaseConnectionId(precheck.id);
  if (id.isNull)
    return errorResponse("Database connection not found", 404);

  auto result = usecase.deleteDatabaseConnection(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  return successResponse("Database connection deleted successfully", "Deleted", 200, Json
      .emptyObject.set("id", id));
}
}
