/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.data_controller;

import uim.platform.data.privacy.application.usecases.manage.data_controllers;
import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.data_controller;
import uim.platform.data.privacy.presentation.http.json_utils;

class DataControllerController {
  private ManageDataControllersUseCase uc;

  this(ManageDataControllersUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listControllers(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto entry = uc.getController(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Data controller not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateDataControllerRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.headers.get("X-Tenant-Id", "");
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
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      uc.deleteController(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const DataController e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["legalEntityName"] = Json(e.legalEntityName);
    j["contactEmail"] = Json(e.contactEmail);
    j["contactPhone"] = Json(e.contactPhone);
    j["address"] = Json(e.address);
    j["country"] = Json(e.country);
    j["dpoName"] = Json(e.dpoName);
    j["dpoEmail"] = Json(e.dpoEmail);
    j["isActive"] = Json(e.isActive);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);
    return j;
  }
}
