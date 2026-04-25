/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.data_model;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.master_data_integration.application.usecases.manage.data_models;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.data_model;
import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.presentation.http.json_utils;

class DataModelController : PlatformController {
  private ManageDataModelsUseCase uc;

  this(ManageDataModelsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-models", &handleCreate);
    router.get("/api/v1/data-models", &handleList);
    router.get("/api/v1/data-models/*", &handleGetById);
    router.put("/api/v1/data-models/*", &handleUpdate);
    router.delete_("/api/v1/data-models/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataModelRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.namespace = j.getString("namespace");
      r.version_ = j.getString("version");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.keyFields = getStringArray(j, "keyFields");
      r.requiredFields = getStringArray(j, "requiredFields");
      r.createdBy = req.headers.get("X-User-Id", "");

      // Parse field definitions
      auto fieldsArr = jsonObjArray(j, "fields");
      FieldDefinitionDto[] fields;
      foreach (fj; fieldsArr) {
        FieldDefinitionDto fd;
        fd.name = fj.getString("name");
        fd.displayName = fj.getString("displayName");
        fd.type_ = fj.getString("type");
        fd.isRequired = fj.getBoolean("isRequired");
        fd.isKey = fj.getBoolean("isKey");
        fd.defaultValue = fj.getString("defaultValue");
        fd.maxLength = jsonInt(fj, "maxLength");
        fd.referenceModel = fj.getString("referenceModel");
        fd.description = fj.getString("description");
        fields ~= fd;
      }
      r.fields = fields;

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto category = req.params.get("category", "");

      DataModel[] models;
      if (category.length > 0)
        models = uc.listByCategory(tenantId, category);
      else
        models = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (m; models)
        arr ~= serializeModel(m);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(models.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto model = uc.getModel(id);
      if (model.id.isEmpty) {
        writeError(res, 404, "Data model not found");
        return;
      }
      res.writeJsonBody(serializeModel(model), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateDataModelRequest r;
      r.description = j.getString("description");
      r.version_ = j.getString("version");
      r.keyFields = getStringArray(j, "keyFields");
      r.requiredFields = getStringArray(j, "requiredFields");

      auto fieldsArr = jsonObjArray(j, "fields");
      FieldDefinitionDto[] fields;
      foreach (fj; fieldsArr) {
        FieldDefinitionDto fd;
        fd.name = fj.getString("name");
        fd.displayName = fj.getString("displayName");
        fd.type_ = fj.getString("type");
        fd.isRequired = fj.getBoolean("isRequired");
        fd.isKey = fj.getBoolean("isKey");
        fd.defaultValue = fj.getString("defaultValue");
        fd.maxLength = jsonInt(fj, "maxLength");
        fd.referenceModel = fj.getString("referenceModel");
        fd.description = fj.getString("description");
        fields ~= fd;
      }
      r.fields = fields;

      auto result = uc.updateModel(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteModel(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeModel(DataModel m) {
    auto fieldsArr = Json.emptyArray;
    foreach (fd; m.fields) {
      fieldsArr ~= Json.emptyObject
        .set("name", fd.name)
        .set("displayName", fd.displayName)
        .set("type", fd.type_.to!string)
        .set("isRequired", fd.isRequired)
        .set("isKey", fd.isKey)
        .set("defaultValue", fd.defaultValue)
        .set("maxLength", fd.maxLength)
        .set("referenceModel", fd.referenceModel)
        .set("description", fd.description);
    }

    return Json.emptyObject
    .set("id", m.id)
    .set("tenantId", m.tenantId)
    .set("name", m.name)
    .set("namespace", m.namespace)
    .set("version", m.version_)
    .set("description", m.description)
    .set("category", m.category.to!string)
    .set("isActive", m.isActive)
    .set("keyFields", serializeStrArray(m.keyFields))
    .set("requiredFields", serializeStrArray(m.requiredFields))
    .set("fields", fieldsArr)
    .set("createdBy", Json(m.createdBy))
    .set("createdAt", Json(m.createdAt))
    .set("updatedAt", Json(m.updatedAt));
  }
} 
