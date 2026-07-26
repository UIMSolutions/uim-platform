/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.presentation.http.controllers.source_system;

// import uim.platform.identity_provisioning.application.usecases.manage.source_systems;
// import uim.platform.identity_provisioning.application.dto;
// import uim.platform.identity_provisioning.domain.entities.source_system;
// import uim.platform.identity_provisioning.domain.types;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:
class SourceSystemController : ManageHttpController {
  private ManageSourceSystemsUseCase usecase;

  this(ManageSourceSystemsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/source-systems", &handleCreate);
    router.get("/api/v1/source-systems", &handleList);
    router.get("/api/v1/source-systems/*", &handleGet);
    router.put("/api/v1/source-systems/*", &handleUpdate);
    router.delete_("/api/v1/source-systems/*", &handleDelete);
    router.post("/api/v1/source-systems/activate/*", &handleActivate);
    router.post("/api/v1/source-systems/deactivate/*", &handleDeactivate);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateSourceSystemRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.systemType = toSystemType(data.getString("systemType"));
    r.connectionConfig = data.getString("connectionConfig");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createSourceSystem(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Source system created successfully", 201, responseData);
}

override protected Json listHandler(HTTPServerRequest req) {
  auto precheck = super.listHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto items = usecase.listSourceSystems(tenantId);

  auto arr = Json.emptyArray;
  foreach (s; items)
    arr ~= s.toJson;

  auto resp = Json.emptyObject
    .set("items", arr)
    .set("totalCount", items.length);

  return successResponse("Source system list retrieved successfully", 200, resp);
}

override protected Json getHandler(HTTPServerRequest req) {
  auto precheck = super.getHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SourceSystemId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid source system ID", 400);

  auto sys = usecase.getSourceSystem(tenantId, id);
  if (sys.isNull)
    return errorResponse("Source system not found", 404);

  auto responseData = sys.toJson;
  return successResponse("Source system retrieved successfully", 200, responseData);
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SourceSystemId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid source system ID", 400);

  auto data = precheck.data;
  auto r = UpdateSourceSystemRequest();
  r.systemId = id;
  r.tenantId = tenantId;
  r.name = data.getString("name");
  r.description = data.getString("description");
  r.connectionConfig = data.getString("connectionConfig");

  auto result = usecase.updateSourceSystem(r);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Source system updated successfully", 200, responseData);
}

protected Json activateHandler(HTTPServerRequest req) {
  auto precheck = super.postHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SourceSystemId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid source system ID", 400);

  auto result = usecase.activateSystem(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Source system activated successfully", 200, responseData);
}

mixin(HandleTemplate!("handleActivate", "activateHandler"));


protected Json deactivateHandler(HTTPServerRequest req) {
  auto precheck = super.postHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SourceSystemId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid source system ID", 400);

  auto result = usecase.deactivateSystem(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Source system deactivated successfully", 200, responseData);
}

mixin(HandleTemplate!("handleDeactivate", "deactivateHandler"));

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = SourceSystemId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid source system ID", 400);

  auto result = usecase.deleteSourceSystem(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("Source system deleted successfully", 200, responseData);
}

}
