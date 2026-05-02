/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.data_controller;

// import uim.platform.data.privacy.application.usecases.manage.data_controllers;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_controller;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DataControllerController : PlatformController {
  private ManageDataControllersUseCase uc;

  this(ManageDataControllersUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/data-controllers", &handleCreate);
    router.get("/api/v1/data-controllers", &handleList);
    router.get("/api/v1/data-controllers/*", &handleGetById);
    router.put("/api/v1/data-controllers/*", &handleUpdate);
    router.delete_("/api/v1/data-controllers/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataControllerRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.legalEntityName = j.getString("legalEntityName");
      r.contactEmail = j.getString("contactEmail");
      r.contactPhone = j.getString("contactPhone");
      r.address = j.getString("address");
      r.country = j.getString("country");
      r.dpoName = j.getString("dpoName");
      r.dpoEmail = j.getString("dpoEmail");

      auto result = uc.createController(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Data controller created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;

      auto items = uc.listControllers(tenantId);
      auto arr = items.map!(controller => controller.toJson).array.toJson;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", Json(items.length));

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getController(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Data controller not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateDataControllerRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.legalEntityName = j.getString("legalEntityName");
      r.contactEmail = j.getString("contactEmail");
      r.contactPhone = j.getString("contactPhone");
      r.address = j.getString("address");
      r.country = j.getString("country");
      r.dpoName = j.getString("dpoName");
      r.dpoEmail = j.getString("dpoEmail");

      auto result = uc.updateController(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Data controller updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteController(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const DataController e) {
    return Json.emptyObject
    .set("id", e.id)
    .set("tenantId", e.tenantId)
    .set("name", e.name)
    .set("description", e.description)
    .set("legalEntityName", e.legalEntityName)
    .set("contactEmail", e.contactEmail)
    .set("contactPhone", e.contactPhone)
    .set("address", e.address)
    .set("country", e.country)
    .set("dpoName", e.dpoName)
    .set("dpoEmail", e.dpoEmail)
    .set("isActive", e.isActive)
    .set("createdAt", e.createdAt)
    .set("updatedAt", e.updatedAt);
  }
}
