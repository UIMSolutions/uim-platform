/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.proxy_system;

// import uim.platform.identity.provisioning.application.usecases.manage.proxy_systems;
// import uim.platform.identity.provisioning.application.dto;
// import uim.platform.identity.provisioning.domain.entities.proxy_system;
// import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning;

mixin(ShowModule!());

@safe:
class ProxySystemController : ManageHttpController {
  private ManageProxySystemsUseCase usecase;

  this(ManageProxySystemsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/proxy-systems", &handleCreate);
    router.get("/api/v1/proxy-systems", &handleList);
    router.get("/api/v1/proxy-systems/*", &handleGet);
    router.put("/api/v1/proxy-systems/*", &handleUpdate);
    router.delete_("/api/v1/proxy-systems/*", &handleDelete);
    router.post("/api/v1/proxy-systems/activate/*", &handleActivate);
    router.post("/api/v1/proxy-systems/deactivate/*", &handleDeactivate);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateProxySystemRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.systemType = toSystemType(data.getString("systemType"));
    r.connectionConfig = data.getString("connectionConfig");
    r.sourceSystemId = data.getString("sourceSystemId");
    r.targetSystemId = data.getString("targetSystemId");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createProxySystem(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Proxy system created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenantId = precheck.tenantId;
    auto items = usecase.listProxySystems(
      tenantId);
    auto arr = items.map!(s => s.toJson).array.toJson;
    auto list = items.map!(
      item => item.toJson()).array.toJson;
    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Proxy systems retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    auto sys = usecase.getProxySystem(tenantId, id);
    if (sys.isNull)
      return errorResponse("Proxy system not found", 404);
    auto responseData = sys
      .toJson;
    return successResponse("Proxy system retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    
    auto data = precheck.data;
    auto r = UpdateProxySystemRequest();
    r.id = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString(
      "description");
    r.connectionConfig = data.getString("connectionConfig");

    auto result = usecase.updateProxySystem(r);
    if (result.isSuccess) {
      auto resp = Json.emptyObject
        .set("id", result.id);
      res.writeJsonBody(resp, 200);
    } else {
      auto status = result.message == "Proxy system not found" ? 404 : 400;
      writeError(res, status, result.message);
    }
  }
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck
      .tenantId;
    auto result = usecase.activateSystem(tenantId, id);
    if (result.isSuccess) {
      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("status", "active");
      res.writeJsonBody(resp, 200);
    } else {
      auto status = result.message == "Proxy system not found" ? 404 : 400;
      writeError(res, status, result.message);
    }
  } catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
  try {
    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck
      .tenantId;
    auto result = usecase.deactivateSystem(tenantId, id);
    if (result.isSuccess) {
      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("status", "inactive");
      res.writeJsonBody(resp, 200);
    } else {
      writeError(res, 404, result.message);
    }
  } catch (Exception e) {
    writeError(res, 500, "Internal server error");
  }
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;
  auto tenantId = precheck.tenantId;
  auto id = precheck
    .id;
  auto tenantId = precheck.tenantId;
  auto result = usecase.deleteProxySystem(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 404);
  auto resp = Json.emptyObject.set("id", result
      .id);
  return successResponse(
    "Proxy system deleted successfully", 200, resp);
}
}
