/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.distribution;

// import uim.platform.master_data_integration.application.usecases.manage.distribution_models;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.distribution_model;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class DistributionController : ManageController {
  private ManageDistributionModelsUseCase usecase;

  this(ManageDistributionModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/distribution-models", &handleCreate);
    router.get("/api/v1/distribution-models", &handleList);
    router.get("/api/v1/distribution-models/*", &handleGet);
    router.put("/api/v1/distribution-models/*", &handleUpdate);
    router.delete_("/api/v1/distribution-models/*", &handleDelete);
    router.post("/api/v1/distribution-models/activate/*", &handleActivate);
    router.post("/api/v1/distribution-models/deactivate/*", &handleDeactivate);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateDistributionModelRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.direction = data.getString("direction");
      r.sourceClientId = data.getString("sourceClientId");
      r.targetClientIds = data.getStrings("targetClientIds");
      r.categories = data.getStrings("categories");
      r.dataModelIds = data.getStrings("dataModelIds");
      r.filterRuleIds = data.getStrings("filterRuleIds");
      r.autoReplicate = data.getBoolean("autoReplicate");
      r.cronSchedule = data.getString("cronSchedule");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Distribution model created");

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
      auto status = req.params.get("status", "");

      DistributionModel[] models;
      if (status.length > 0)
        models = usecase.listByStatus(tenantId, status);
      else
        models = usecase.listByTenant(tenantId);

      auto arr = models.map!(m => m.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", models.length)
        .set("message", "Distribution models retrieved successfully");

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
        writeError(res, 404, "Distribution model not found");
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
      UpdateDistributionModelRequest r;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.status = data.getString("status");
      r.targetClientIds = data.getStrings("targetClientIds");
      r.categories = data.getStrings("categories");
      r.dataModelIds = data.getStrings("dataModelIds");
      r.filterRuleIds = data.getStrings("filterRuleIds");
      r.autoReplicate = data.getBoolean("autoReplicate");
      r.cronSchedule = data.getString("cronSchedule");

      auto result = usecase.updateModel(id, r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Distribution model updated");

        res.writeJsonBody(resp, 200);
      } else
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
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Distribution model deleted");

        res.writeJsonBody(resp, 204);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.activate(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Distribution model activated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.deactivate(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeModel(DistributionModel m) {
    auto catsArr = Json.emptyArray;
    foreach (cat; m.categories)
      catsArr ~= Json(cat.to!string);

    return Json.emptyObject
      .set("id", m.id)
      .set("tenantId", m.tenantId)
      .set("name", m.name)
      .set("description", m.description)
      .set("status", m.status.to!string)
      .set("direction", m.direction.to!string)
      .set("sourceClientId", m.sourceClientId)
      .set("targetClientIds", serializeStrArray(m.targetClientIds))
      .set("categories", catsArr)
      .set("dataModelIds", serializeStrArray(m.dataModelIds))
      .set("filterRuleIds", serializeStrArray(m.filterRuleIds))
      .set("autoReplicate", m.autoReplicate)
      .set("cronSchedule", m.cronSchedule)
      .set("createdBy", m.createdBy)
      .set("createdAt", m.createdAt)
      .set("updatedAt", m.updatedAt);
  }
}
