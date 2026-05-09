/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.distribution;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;


import uim.platform.master_data_integration.application.usecases.manage.distribution_models;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.distribution_model;
import uim.platform.master_data_integration.domain.types;

class DistributionController : PlatformController {
  private ManageDistributionModelsUseCase usecase;

  this(ManageDistributionModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/distribution-models", &handleCreate);
    router.get("/api/v1/distribution-models", &handleList);
    router.get("/api/v1/distribution-models/*", &handleGetById);
    router.put("/api/v1/distribution-models/*", &handleUpdate);
    router.delete_("/api/v1/distribution-models/*", &handleDelete);
    router.post("/api/v1/distribution-models/activate/*", &handleActivate);
    router.post("/api/v1/distribution-models/deactivate/*", &handleDeactivate);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDistributionModelRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.direction = j.getString("direction");
      r.sourceClientId = j.getString("sourceClientId");
      r.targetClientIds = getStrings(j, "targetClientIds");
      r.categories = getStrings(j, "categories");
      r.dataModelIds = getStrings(j, "dataModelIds");
      r.filterRuleIds = getStrings(j, "filterRuleIds");
      r.autoReplicate = j.getBoolean("autoReplicate");
      r.cronSchedule = j.getString("cronSchedule");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Distribution model created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto status = req.params.get("status", "");

      DistributionModel[] models;
      if (status.length > 0)
        models = usecase.listByStatus(tenantId, status);
      else
        models = usecase.listByTenant(tenantId);

      auto arr = models.map!(m => m.toJson).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", models.length)
        .set("message", "Distribution models retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
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

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateDistributionModelRequest r;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.status = j.getString("status");
      r.targetClientIds = getStrings(j, "targetClientIds");
      r.categories = getStrings(j, "categories");
      r.dataModelIds = getStrings(j, "dataModelIds");
      r.filterRuleIds = getStrings(j, "filterRuleIds");
      r.autoReplicate = j.getBoolean("autoReplicate");
      r.cronSchedule = j.getString("cronSchedule");

      auto result = usecase.updateModel(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Distribution model updated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.deleteModel(id);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Distribution model deleted");

        res.writeJsonBody(resp, 204);
      } else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.activate(id);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Distribution model activated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = usecase.deactivate(id);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
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
