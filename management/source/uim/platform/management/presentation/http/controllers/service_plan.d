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
class ServicePlanController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto data = precheck.data;
      CreateServicePlanRequest r;
      r.serviceName = j.getString("serviceName");
      r.serviceDisplayName = j.getString("serviceDisplayName");
      r.planName = j.getString("planName");
      r.planDisplayName = j.getString("planDisplayName");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.pricingModel = j.getString("pricingModel");
      r.isFree = j.getBoolean("isFree");
      r.isBeta = j.getBoolean("isBeta");
      r.availableRegions = getStrings(j, "availableRegions");
      r.maxQuota = j.getInteger("maxQuota");
      r.unit = j.getString("unit");
      r.supportedPlatforms = getStrings(j, "supportedPlatforms");
      r.providerDisplayName = j.getString("providerDisplayName");
      r.metadata = jsonStrMap(j, "metadata");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto serviceName = req.params.get("serviceName");
      auto category = req.params.get("category");
      auto region = req.params.get("region");

      ServicePlan[] items;
      if (serviceName.length > 0)
        items = usecase.listByService(serviceName);
      else if (category.length > 0)
        items = usecase.listByCategory(category);
      else if (region.length > 0)
        items = usecase.listByRegion(region);
      else
        items = usecase.listAll();

      auto arr = items.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Service plans retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto p = usecase.getById(tenantId, id);
      if (p.isNull) {
        writeError(res, 404, "Service plan not found");
        return;
      }
      res.writeJsonBody(p.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = extractId(req.requestURI);
      auto data = precheck.data;
      UpdateServicePlanRequest r;
      r.planDisplayName = j.getString("planDisplayName");
      r.description = j.getString("description");
      r.availableRegions = getStrings(j, "availableRegions");
      r.maxQuota = j.getInteger("maxQuota");
      r.isBeta = j.getBoolean("isBeta");
      r.provisionable = j.getBoolean("provisionable", true);
      r.metadata = jsonStrMap(j, "metadata");

      auto result = usecase.update(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("message", "Service plan updated successfully"), 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ServicePlanId(extractId(req.requestURI));
      auto result = usecase.deleteServicePlan(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("message", "Service plan deleted successfully"), 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}

private Json serializeServicePlan(ServicePlan plan) {
  return Json.emptyObject
    .set("id", plan.id)
    .set("serviceName", plan.serviceName)
    .set("serviceDisplayName", plan.serviceDisplayName)
    .set("planName", plan.planName)
    .set("planDisplayName", plan.planDisplayName)
    .set("description", plan.description)
    .set("category", to!string(plan.category))
    .set("pricingModel", to!string(plan.pricingModel))
    .set("isFree", plan.isFree)
    .set("isBeta", plan.isBeta)
    .set("availableRegions", plan.availableRegions.toJson)
    .set("maxQuota", plan.maxQuota)
    .set("unit", plan.unit)
    .set("supportedPlatforms", plan.supportedPlatforms.toJson)
    .set("providerDisplayName", plan.providerDisplayName)
    .set("provisionable", plan.provisionable)
    .set("createdAt", plan.createdAt)
    .set("updatedAt", plan.updatedAt)
    .set("metadata", plan.metadata);
}

