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

import uim.platform.master_data_integration.application.usecases.manage_data_models;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.data_model;
import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.presentation.http.json_utils;

class DataModelController
{
  private ManageDataModelsUseCase uc;

  this(ManageDataModelsUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/data-models", &handleCreate);
    router.get("/api/v1/data-models", &handleList);
    router.get("/api/v1/data-models/*", &handleGetById);
    router.put("/api/v1/data-models/*", &handleUpdate);
    router.delete_("/api/v1/data-models/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      CreateDataModelRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.namespace = j.getString("namespace");
      r.version_ = j.getString("version");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.keyFields = jsonStrArray(j, "keyFields");
      r.requiredFields = jsonStrArray(j, "requiredFields");
      r.createdBy = req.headers.get("X-User-Id", "");

      // Parse field definitions
      auto fieldsArr = jsonObjArray(j, "fields");
      FieldDefinitionDto[] fields;
      foreach (ref fj; fieldsArr)
      {
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
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto category = req.params.get("category", "");

      DataModel[] models;
      if (category.length > 0)
        models = uc.listByCategory(tenantId, category);
      else
        models = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref m; models)
        arr ~= serializeModel(m);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) models.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto model = uc.getModel(id);
      if (model.id.length == 0)
      {
        writeError(res, 404, "Data model not found");
        return;
      }
      res.writeJsonBody(serializeModel(model), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateDataModelRequest r;
      r.description = j.getString("description");
      r.version_ = j.getString("version");
      r.keyFields = jsonStrArray(j, "keyFields");
      r.requiredFields = jsonStrArray(j, "requiredFields");

      auto fieldsArr = jsonObjArray(j, "fields");
      FieldDefinitionDto[] fields;
      foreach (ref fj; fieldsArr)
      {
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
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteModel(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeModel(ref DataModel m)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(m.id);
    j["tenantId"] = Json(m.tenantId);
    j["name"] = Json(m.name);
    j["namespace"] = Json(m.namespace);
    j["version"] = Json(m.version_);
    j["description"] = Json(m.description);
    j["category"] = Json(m.category.to!string);
    j["isActive"] = Json(m.isActive);
    j["keyFields"] = serializeStrArray(m.keyFields);
    j["requiredFields"] = serializeStrArray(m.requiredFields);

    auto fieldsArr = Json.emptyArray;
    foreach (ref fd; m.fields)
    {
      auto fj = Json.emptyObject;
      fj["name"] = Json(fd.name);
      fj["displayName"] = Json(fd.displayName);
      fj["type"] = Json(fd.type_.to!string);
      fj["isRequired"] = Json(fd.isRequired);
      fj["isKey"] = Json(fd.isKey);
      fj["defaultValue"] = Json(fd.defaultValue);
      fj["maxLength"] = Json(cast(long) fd.maxLength);
      fj["referenceModel"] = Json(fd.referenceModel);
      fj["description"] = Json(fd.description);
      fieldsArr ~= fj;
    }
    j["fields"] = fieldsArr;

    j["createdBy"] = Json(m.createdBy);
    j["createdAt"] = Json(m.createdAt);
    j["modifiedAt"] = Json(m.modifiedAt);
    return j;
  }
}
