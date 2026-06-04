/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.org;

// import uim.platform.foundry.application.usecases.manage.orgs;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.organization;
import uim.platform.foundry;

class OrgController : ManageHttpController {
  private ManageOrgsUseCase useCase;

  this(ManageOrgsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/orgs", &handleCreate);
    router.get("/api/v1/orgs", &handleList);
    router.post("/api/v1/orgs/suspend/*", &handleSuspend);
    router.post("/api/v1/orgs/activate/*", &handleActivate);
    router.get("/api/v1/orgs/*", &handleGet);
    router.put("/api/v1/orgs/*", &handleUpdate);
    router.delete_("/api/v1/orgs/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateOrgRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.memoryQuotaMb = data.getInteger("memoryQuotaMb", 0);
    r.instanceMemoryLimitMb = data.getInteger("instanceMemoryLimitMb", 0);
    r.totalRoutes = data.getInteger("totalRoutes", 0);
    r.totalServices = data.getInteger("totalServices", 0);
    r.totalAppInstances = data.getInteger("totalAppInstances", 0);
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = useCase.createOrg(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("", 0, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto list = useCase.listOrgs(tenantId).map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Organization list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = OrgId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid organization ID", 400);

    auto org = useCase.getOrg(tenantId, id);
    if (org.isNull)
      return errorResponse("Organization not found", 404);

    auto responseData = org.toJson();
    return successResponse("Organization retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = OrgId(precheck.id);

    auto data = precheck.data;
    auto r = UpdateOrgRequest();
    r.orgId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.memoryQuotaMb = data.getInteger("memoryQuotaMb", 0);
    r.instanceMemoryLimitMb = data.getInteger("instanceMemoryLimitMb", 0);
    r.totalRoutes = data.getInteger("totalRoutes", 0);
    r.totalServices = data.getInteger("totalServices", 0);
    r.totalAppInstances = data.getInteger("totalAppInstances", 0);

    auto result = useCase.updateOrg(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Organization updated successfully", "Updated", 200, responseData);
  }

  protected Json suspendHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = OrgId(precheck.id);

    auto result = useCase.suspendOrg(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Organization suspended successfully", "Suspended", 200, responseData);
  }

  protected void handleSuspend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = suspendHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = OrgId(precheck.id);

    auto result = useCase.activateOrg(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Organization activated successfully", "Activated", 200, responseData);
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = activateHandler(req);
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
    auto id = OrgId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid organization ID", 400);

    auto result = useCase.deleteOrg(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Organization deleted successfully", "Deleted", 200, responseData);
  }
}
