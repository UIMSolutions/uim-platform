/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.service_plan;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// 
// import uim.platform.management.application.usecases.manage.service_plans;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.types;
// import uim.platform.management.presentation.http.json_utils;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class ServicePlanController : PlatformController {
  private ManageServicePlansUseCase uc;

  this(ManageServicePlansUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/service-plans", &handleCreate);
    router.get("/api/v1/service-plans", &handleList);
    router.get("/api/v1/service-plans/*", &handleGet);
    router.put("/api/v1/service-plans/*", &handleUpdate);
    router.delete_("/api/v1/service-plans/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
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
      r.availableRegions = getStringArray(j, "availableRegions");
      r.maxQuota = j.getInteger("maxQuota");
      r.unit = j.getString("unit");
      r.supportedPlatforms = getStringArray(j, "supportedPlatforms");
      r.providerDisplayName = j.getString("providerDisplayName");
      r.metadata = jsonStrMap(j, "metadata");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto serviceName = req.params.get("serviceName");
      auto category = req.params.get("category");
      auto region = req.params.get("region");

      ServicePlan[] items;
      if (serviceName.length > 0)
        items = uc.listByService(serviceName);
      else if (category.length > 0)
        items = uc.listByCategory(category);
      else if (region.length > 0)
        items = uc.listByRegion(region);
      else
        items = uc.listAll();

      auto arr = Json.emptyArray;
      foreach (p; items)
        arr ~= serializeServicePlan(p);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto p = uc.getById(id);
      if (p.id.isEmpty) {
        writeError(res, 404, "Service plan not found");
        return;
      }
      res.writeJsonBody(serializeServicePlan(p), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto j = req.json;
      UpdateServicePlanRequest r;
      r.planDisplayName = j.getString("planDisplayName");
      r.description = j.getString("description");
      r.availableRegions = getStringArray(j, "availableRegions");
      r.maxQuota = j.getInteger("maxQuota");
      r.isBeta = j.getBoolean("isBeta");
      r.provisionable = j.getBoolean("provisionable", true);
      r.metadata = jsonStrMap(j, "metadata");

      auto result = uc.update(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractId(req.requestURI);
      auto result = uc.remove(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
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

