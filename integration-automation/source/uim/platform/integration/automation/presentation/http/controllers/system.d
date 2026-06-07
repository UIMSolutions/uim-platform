/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.system;

// import uim.platform.integration.automation.application.usecases.manage.systems;
// import uim.platform.integration.automation.application.dto;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.system_connection;
import uim.platform.integration.automation;

// mixin(ShowModule!());

@safe:
class SystemController : ManageHttpController {
  private ManageSystemsUseCase useCase;

  this(ManageSystemsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/systems", &handleCreate);
    router.get("/api/v1/systems", &handleList);
    router.get("/api/v1/systems/*", &handleGet);
    router.put("/api/v1/systems/*", &handleUpdate);
    router.delete_("/api/v1/systems/*", &handleDelete);
    router.post("/api/v1/systems/test/*", &handleTestConnection);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateSystemRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.systemType = parseSystemType(data.getString("systemType"));
    r.host = data.getString("host");
    r.port = getUshort(j, "port");
    r.client = data.getString("client");
    r.protocol = data.getString("protocol");
    r.environment = data.getString("environment");
    r.region = data.getString("region");
    r.systemId = data.getString("systemId");
    r.tenant = data.getString("tenant");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = useCase.createSystem(r);
    if (result.isSuccess()) {
      auto resp = Json.emptyObject
        .set("id", result.id);

      res.writeJsonBody(resp, 201);
    } else {
      writeError(res, 400, result.message);
    }
  }
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

override protected Json listHandler(HTTPServerRequest req) {
  auto precheck = super.listHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto systems = useCase.listSystems(tenantId);

  auto arr = systems.map!(s => s.toJson).array.toJson;

  auto resp = Json.emptyObject
    .set("items", arr)
    .set("totalCount", systems.length);

  return successResponse("System list retrieved successfully", 200, resp);
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SystemConnectionId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid system ID", 400);

  auto sys = useCase.getSystem(tenantId, id);
  if (sys.isNull)
    return errorResponse("System not found", 404);

  auto responseData = sys.toJson();
  return successResponse("System retrieved successfully", 200, responseData);
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SystemConnectionId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid system ID", 400);

  auto data = precheck.data;
  auto r = UpdateSystemRequest();
  r.connectionId = id;
  r.tenantId = tenantId;
  r.name = data.getString("name");
  r.description = data.getString("description");
  r.systemType = parseSystemType(data.getString("systemType"));
  r.host = data.getString("host");
  r.port = getUshort(j, "port");
  r.client = data.getString("client");
  r.protocol = data.getString("protocol");
  r.status = parseConnectionStatus(data.getString("status"));
  r.environment = data.getString("environment");
  r.region = data.getString("region");
  r.systemId = data.getString("systemId");
  r.tenant = data.getString("tenant");

  auto result = useCase.updateSystem(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto resp = Json.emptyObject.set("id", result.id);
  return successResponse("System updated successfully", 200, resp);

}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SystemConnectionId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid system ID", 400);

  auto result = useCase.deleteSystem(tenantId, id);
  if (result.isSuccess()) {
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("System deleted successfully", 200, resp);
  }

  protected Json getTestConnectionHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SystemConnectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid system ID", 400);

    auto result = useCase.testConnection(tenantId, id);
    if (result.hasError)     return errorResponse(result.message, 400);

      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("connectionStatus", "active");

      return successResponse("Connection test successful", 200, resp);
   
  }
  protected void handleGetTestConnection(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = getTestConnectionHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
