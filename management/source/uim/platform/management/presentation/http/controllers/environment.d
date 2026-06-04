/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.environment;

// 
// import uim.platform.management.application.usecases.manage.environment_instances;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.environment_instance;

import uim.platform.management;

mixin(ShowModule!());
@safe:
class EnvironmentController : ManageHttpController {
  private ManageEnvironmentsUseCase usecase;

  this(ManageEnvironmentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    router.post("/api/v1/environments", &handleCreate);
    router.get("/api/v1/environments", &handleList);
    router.get("/api/v1/environments/*", &handleGet);
    router.put("/api/v1/environments/*", &handleUpdate);
    router.post("/api/v1/environments/deprovision/*", &handleDeprovision);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto subId = SubaccountId(req.params.get("subaccountId"));
    auto envType = req.params.get("environmentType");

    Environment[] items;
    if (envType.length > 0 && !subId.isEmpty)
      items = usecase.listEnvironments(tenantId, subId, envType);
    else if (!subId.isEmpty)
      items = usecase.listEnvironments(tenantId, subId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Environment instance list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateEnvironmentRequest r;
    r.tenantId = tenantId;
    r.subaccountId = data.getString("subaccountId");
    r.globalAccountId = data.getString("globalAccountId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.environmentType = data.getString("environmentType");
    r.planName = data.getString("planName");
    r.landscapeLabel = data.getString("landscapeLabel");
    r.memoryQuotaMb = data.getInteger("memoryQuotaMb");
    r.routeQuota = data.getInteger("routeQuota");
    r.serviceQuota = data.getInteger("serviceQuota");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));
    r.parameters = data.jsonStrMap("parameters");
    r.labels = data.jsonStrMap("labels");

    auto result = usecase.createEnvironment(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Environment instance created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = EnvironmentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid environment instance ID", 400);

    auto inst = usecase.getEnvironment(tenantId, id);
    if (inst.isNull)
      return errorResponse("Environment instance not found", 404);

    auto responseData = inst.toJson();
    return successResponse("Environment instance retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = EnvironmentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid environment instance ID", 400);

    auto data = precheck.data;
    UpdateEnvironmentRequest request;
    request.tenantId = tenantId;
    request.instanceId = id;
    request.description = data.getString("description");
    request.memoryQuotaMb = data.getInteger("memoryQuotaMb");
    request.routeQuota = data.getInteger("routeQuota");
    request.serviceQuota = data.getInteger("serviceQuota");
    request.parameters = data.jsonStrMap("parameters");
    request.labels = data.jsonStrMap("labels");

    auto result = usecase.updateEnvironment(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Environment instance updated successfully", "Updated", 200, responseData);
  }

  protected Json getDesprovisionHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)       
      return precheck;

      auto tenantId = precheck.tenantId;
      auto id = EnvironmentId(precheck.id);
      if (id.isNull)
        return errorResponse("Invalid environment instance ID", 400);

      auto result = usecase.deprovisionEnvironment(tenantId, id);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto responseData = Json.emptyObject.set("id", result.id);
      return successResponse("Environment instance deprovisioned successfully", "Deprovisioned", 200, responseData);

  }
  protected void handleDeprovision(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = getDesprovisionHandler(req);
      res.writeJsonBody(response.data, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
