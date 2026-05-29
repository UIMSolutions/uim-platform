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
class DataControllerController : ManageController {
  private ManageDataControllersUseCase usecase;

  this(ManageDataControllersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-controllers", &handleCreate);
    router.get("/api/v1/data-controllers", &handleList);
    router.get("/api/v1/data-controllers/*", &handleGet);
    router.put("/api/v1/data-controllers/*", &handleUpdate);
    router.delete_("/api/v1/data-controllers/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateDataControllerRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.legalEntityName = data.getString("legalEntityName");
      r.contactEmail = data.getString("contactEmail");
      r.contactPhone = data.getString("contactPhone");
      r.address = data.getString("address");
      r.country = data.getString("country");
      r.dpoName = data.getString("dpoName");
      r.dpoEmail = data.getString("dpoEmail");

      auto result = usecase.createController(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Data controller created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

      auto items = usecase.listControllers(tenantId);
      auto arr = items.map!(controller => controller.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DataControllerId(precheck.id);

      auto entry = usecase.getController(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Data controller not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      
      UpdateDataControllerRequest r;
      r.tenantId = tenantId;
      r.controllerId = DataControllerId(precheck.id);
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.legalEntityName = data.getString("legalEntityName");
      r.contactEmail = data.getString("contactEmail");
      r.contactPhone = data.getString("contactPhone");
      r.address = data.getString("address");
      r.country = data.getString("country");
      r.dpoName = data.getString("dpoName");
      r.dpoEmail = data.getString("dpoEmail");

      auto result = usecase.updateController(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Data controller updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto controllerId = DataControllerId(precheck.id);

      usecase.deleteController(tenantId, controllerId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
