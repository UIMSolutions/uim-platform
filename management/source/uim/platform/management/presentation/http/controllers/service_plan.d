/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.service_plan;

// 
// import uim.platform.management.application.usecases.manage.service_plans;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class ServicePlanController : ManageHttpController {
  private ManageServicePlansUseCase usecase;

  this(ManageServicePlansUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/service-plans", &handleCreate);
    router.get("/api/v1/service-plans", &handleList);
    router.get("/api/v1/service-plans/*", &handleGet);
    router.put("/api/v1/service-plans/*", &handleUpdate);
    router.delete_("/api/v1/service-plans/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateServicePlanRequest r;
    r.serviceName = data.getString("serviceName");
    r.serviceDisplayName = data.getString("serviceDisplayName");
    r.planName = data.getString("planName");
    r.planDisplayName = data.getString("planDisplayName");
    r.description = data.getString("description");
    r.category = data.getString("category");
    r.pricingModel = data.getString("pricingModel");
    r.isFree = data.getBoolean("isFree");
    r.isBeta = data.getBoolean("isBeta");
    r.availableRegions = data.getStrings("availableRegions");
    r.maxQuota = data.getInteger("maxQuota");
    r.unit = data.getString("unit");
    r.supportedPlatforms = data.getStrings("supportedPlatforms");
    r.providerDisplayName = data.getString("providerDisplayName");
    r.metadata = data.jsonStrMap("metadata");

    auto result = usecase.createPlan(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service plan created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto serviceName = req.params.get("serviceName");
    auto category = req.params.get("category");
    auto region = req.params.get("region");

    ServicePlan[] items;
    if (serviceName.length > 0)
      items = usecase.listPlansByService(tenantId, serviceName);
    else if (category.length > 0)
      items = usecase.listPlansByCategory(tenantId, category);
    else if (region.length > 0)
      items = usecase.listPlansByRegion(tenantId, region);
    else
      items = usecase.listPlans(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Service plan list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ServicePlanId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service plan ID", 400);

    auto p = usecase.getPlan(tenantId, id);
    if (p.isNull)
      return errorResponse("Service plan not found", 404);

    auto responseData = p.toJson;
    return successResponse("Service plan retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ServicePlanId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service plan ID", 400);

    auto data = precheck.data;
    UpdateServicePlanRequest r;
    r.tenantId = tenantId;
    r.planId = id;
    r.planDisplayName = data.getString("planDisplayName");
    r.description = data.getString("description");
    r.availableRegions = data.getStrings("availableRegions");
    r.maxQuota = data.getInteger("maxQuota");
    r.isBeta = data.getBoolean("isBeta");
    r.provisionable = data.getBoolean("provisionable", true);
    r.metadata = data.jsonStrMap("metadata");

    auto result = usecase.updatePlan(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service plan updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ServicePlanId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid service plan ID", 400);

    auto result = usecase.deletePlan(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Service plan deleted successfully", "Deleted", 200, responseData);
  }
}
