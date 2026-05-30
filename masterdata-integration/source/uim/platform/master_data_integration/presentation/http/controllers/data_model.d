/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.data_model;

// import uim.platform.master_data_integration.application.usecases.manage.data_models;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.data_model;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class DataModelController : ManageController {
  private ManageDataModelsUseCase usecase;

  this(ManageDataModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-models", &handleCreate);
    router.get("/api/v1/data-models", &handleList);
    router.get("/api/v1/data-models/*", &handleGet);
    router.put("/api/v1/data-models/*", &handleUpdate);
    router.delete_("/api/v1/data-models/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateDataModelRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.namespace = data.getString("namespace");
      r.version_ = data.getString("version");
      r.description = data.getString("description");
      r.category = data.getString("category");
      r.keyFields = data.getStrings("keyFields");
      r.requiredFields = data.getStrings("requiredFields");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      // Parse field definitions
      auto fieldsArr = jsonObjArray(j, "fields");
      FieldDefinitionDto[] fields;
      foreach (fj; fieldsArr) {
        FieldDefinitionDto fd;
        fd.name = fdata.getString("name");
        fd.displayName = fdata.getString("displayName");
        fd.type_ = fdata.getString("type");
        fd.isRequired = fdata.getBoolean("isRequired");
        fd.isKey = fdata.getBoolean("isKey");
        fd.defaultValue = fdata.getString("defaultValue");
        fd.maxLength = jsonInt(fj, "maxLength");
        fd.referenceModel = fdata.getString("referenceModel");
        fd.description = fdata.getString("description");
        fields ~= fd;
      }
      r.fields = fields;

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Data model created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto category = req.params.get("category", "");

      DataModel[] models = category.length > 0
        ? usecase.listByCategory(tenantId, category) : usecase.listByTenant(tenantId);

      auto arr = models.map!(m => m.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(models.length))
        .set("message", "Data models retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto model = usecase.getModel(id);
      if (model.isNull) {
        writeError(res, 404, "Data model not found");
        return;
      }
      res.writeJsonBody(model.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      UpdateDataModelRequest r;
      r.description = data.getString("description");
      r.version_ = data.getString("version");
      r.keyFields = data.getStrings("keyFields");
      r.requiredFields = data.getStrings("requiredFields");

      auto fieldsArr = jsonObjArray(j, "fields");
      FieldDefinitionDto[] fields;
      foreach (fj; fieldsArr) {
        FieldDefinitionDto fd;
        fd.name = fdata.getString("name");
        fd.displayName = fdata.getString("displayName");
        fd.type_ = fdata.getString("type");
        fd.isRequired = fdata.getBoolean("isRequired");
        fd.isKey = fdata.getBoolean("isKey");
        fd.defaultValue = fdata.getString("defaultValue");
        fd.maxLength = jsonInt(fj, "maxLength");
        fd.referenceModel = fdata.getString("referenceModel");
        fd.description = fdata.getString("description");
        fields ~= fd;
      }
      r.fields = fields;

      auto result = usecase.updateModel(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.deleteModel(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
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
