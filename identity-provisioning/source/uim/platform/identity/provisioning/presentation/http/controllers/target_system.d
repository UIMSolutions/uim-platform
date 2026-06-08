/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.presentation.http.target_system;

// import uim.platform.identity.provisioning.application.usecases.manage.target_systems;
// import uim.platform.identity.provisioning.application.dto;
// import uim.platform.identity.provisioning.domain.entities.target_system;
// import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning;

// mixin(ShowModule!());

@safe:
class TargetSystemController : ManageHttpController {
  private ManageTargetSystemsUseCase usecase;

  this(ManageTargetSystemsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/target-systems", &handleCreate);
    router.get("/api/v1/target-systems", &handleList);
    router.get("/api/v1/target-systems/*", &handleGet);
    router.put("/api/v1/target-systems/*", &handleUpdate);
    router.delete_("/api/v1/target-systems/*", &handleDelete);
    router.post("/api/v1/target-systems/activate/*", &handleActivate);
    router.post("/api/v1/target-systems/deactivate/*", &handleDeactivate);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateTargetSystemRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.systemType = parseSystemType(data.getString("systemType"));
    r.connectionConfig = data.getString("connectionConfig");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createTargetSystem(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Target system created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listTargetSystems(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Target systems retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TargetSystemId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid target system ID", 400);

    auto sys = usecase.getTargetSystem(tenantId, id);
    if (sys.isNull)
      return errorResponse("Target system not found", 404);

    auto responseData = sys.toJson();
    return successResponse("Target system retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TargetSystemId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid target system ID", 400);

    auto data = precheck.data;
    auto r = UpdateTargetSystemRequest();
    r.systemId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString(
      "description");
    r.connectionConfig = data.getString("connectionConfig");

    auto result = usecase.updateTargetSystem(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);
    return successResponse("Target system updated successfully", 200, resp);
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TargetSystemId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid target system ID", 400);

    auto result = usecase.activateSystem(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", "active");
    return successResponse("Target system activated successfully", 200, resp);
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = activateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json deactivateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TargetSystemId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid target system ID", 400);

    auto result = usecase.deactivateSystem(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", "inactive");
    return successResponse("Target system deactivated successfully", 200, resp);
  }

  protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = deactivateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TargetSystemId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid target system ID", 400);

    auto result = usecase.deleteTargetSystem(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Target system deleted successfully", 200, resp);
  }
}
