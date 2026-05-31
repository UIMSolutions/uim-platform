/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.personal_data_model;

// import uim.platform.data.privacy.application.usecases.manage.personal_data_models;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.personal_data_model;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class PersonalDataModelController : ManageController {
  private ManagePersonalDataModelsUseCase usecase;

  this(ManagePersonalDataModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/personal-data-models", &handleCreate);
    router.get("/api/v1/personal-data-models", &handleList);
    router.get("/api/v1/personal-data-models/special", &handleListSpecial);
    router.get("/api/v1/personal-data-models/*", &handleGet);
    router.put("/api/v1/personal-data-models/*", &handleUpdate);
    router.delete_("/api/v1/personal-data-models/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreatePersonalDataModelRequest r;
      r.tenantId = tenantId;
      r.fieldName = data.getString("fieldName");
      r.fieldDescription = data.getString("fieldDescription");
      r.category = data.getString("category");
      r.sensitivity = data.getString("sensitivity");
      r.sourceSystem = data.getString("sourceSystem");
      r.sourceEntity = data.getString("sourceEntity");
      r.subjectType = data.getString("subjectType");
      r.isSpecialCategory = data.getBoolean("isSpecialCategory");
      r.legalReference = data.getString("legalReference");

      auto result = usecase.createModel(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Personal data model created successfully");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto catParam = req.headers.get("X-Category-Filter", "");

      PersonalDataModel[] items = catParam.length > 0
        ? usecase.listModels(tenantId, catParam.to!PersonalDataCategory)
        : usecase.listModels(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Personal data models retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleListSpecial(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

      auto items = usecase.listSpecialCategories(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Special category personal data models retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = PersonalDataModelId(precheck.id);

      auto entry = usecase.getModel(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Personal data model not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      UpdatePersonalDataModelRequest r;
      r.id = PersonalDataModelId(precheck.id);
      r.tenantId = tenantId;
      r.fieldName = data.getString("fieldName");
      r.fieldDescription = data.getString("fieldDescription");
      r.category = data.getString("category");
      r.sensitivity = data.getString("sensitivity");
      r.sourceSystem = data.getString("sourceSystem");
      r.sourceEntity = data.getString("sourceEntity");
      r.isSpecialCategory = data.getBoolean("isSpecialCategory");
      r.legalReference = data.getString("legalReference");

      auto result = usecase.updateModel(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Personal data model updated successfully");
            
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = PersonalDataModelId(precheck.id);
 
      usecase.deleteModel(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

}
