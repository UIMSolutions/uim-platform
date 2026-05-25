/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.cleansing_rule;




// import uim.platform.data_quality.application.usecases.manage.cleansing_rules;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.cleansing_rule;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class CleansingRuleController : PlatformController {
  private ManageCleansingRulesUseCase usecase;

  this(ManageCleansingRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/cleansing-rules", &handleCreate);
    router.get("/api/v1/cleansing-rules", &handleList);
    router.get("/api/v1/cleansing-rules/*", &handleGet);
    router.put("/api/v1/cleansing-rules/*", &handleUpdate);
    router.delete_("/api/v1/cleansing-rules/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreateCleansingRuleRequest();
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.datasetPattern = j.getString("datasetPattern");
      r.fieldName = j.getString("fieldName");
      r.action = j.getString("action");
      r.findPattern = j.getString("findPattern");
      r.replaceWith = j.getString("replaceWith");
      r.defaultValue = j.getString("defaultValue");
      r.lookupDataset = j.getString("lookupDataset");
      r.lookupField = j.getString("lookupField");
      r.trimWhitespace = j.getBoolean("trimWhitespace");
      r.normalizeCase = j.getBoolean("normalizeCase");
      r.caseMode = j.getString("caseMode");
      r.removeDiacritics = j.getBoolean("removeDiacritics");
      r.category = j.getString("category");
      r.priority = j.getInteger("priority");

      auto result = usecase.createCleansingRule(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Cleansing rule created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto rules = usecase.listCleansingRules(tenantId);
      auto arr = rules.map!(r => r.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(rules.length))
        .set("message", "Cleansing rules retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);
      auto rule = usecase.getCleansingRule(tenantId, id);
      if (rule.isNull) {
        writeError(res, 404, "Cleansing rule not found");
        return;
      }
      res.writeJsonBody(rule.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = UpdateCleansingRuleRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.datasetPattern = j.getString("datasetPattern");
      r.fieldName = j.getString("fieldName");
      r.action = j.getString("action");
      r.status = j.getString("status");
      r.findPattern = j.getString("findPattern");
      r.replaceWith = j.getString("replaceWith");
      r.defaultValue = j.getString("defaultValue");
      r.lookupDataset = j.getString("lookupDataset");
      r.lookupField = j.getString("lookupField");
      r.trimWhitespace = j.getBoolean("trimWhitespace");
      r.normalizeCase = j.getBoolean("normalizeCase");
      r.caseMode = j.getString("caseMode");
      r.removeDiacritics = j.getBoolean("removeDiacritics");
      r.category = j.getString("category");
      r.priority = j.getInteger("priority");

      auto result = usecase.update(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Cleansing rule updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);

      auto result = usecase.deleteCleansingRule(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
