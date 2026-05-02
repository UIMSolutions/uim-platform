/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.presentation.http.controllers.validate;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.quality.application.usecases.validate_data;
// import uim.platform.data.quality.application.dto;
// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.validation_result;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class ValidateController : PlatformController {
  private ValidateDataUseCase uc;

  this(ValidateDataUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/validate", &handleValidate);
    router.post("/api/v1/validate/batch", &handleValidateBatch);
    router.get("/api/v1/validate/results/*", &handleGetResult);
  }

  private void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = ValidateRecordRequest();
      r.tenantId = req.getTenantId;
      r.datasetId = j.getString("datasetId");
      r.recordId = j.getString("recordId");
      r.fieldValues = jsonStrMap(j, "fieldValues");

      auto result = uc.validateRecord(r);
      res.writeJsonBody(result.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleValidateBatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = ValidateBatchRequest();
      r.tenantId = req.getTenantId;
      r.datasetId = j.getString("datasetId");

      if ("records" in j && j["records"].isArray) {
        foreach (item; j["records"].toArray) {
          if (item.isObject) {
            RecordFieldValues rfv;
            rfv.recordId = item.getString("recordId");
            rfv.fieldValues = jsonStrMap(item, "fieldValues");
            r.records ~= rfv;
          }
        }
      }

      auto results = uc.validateBatch(r);
      auto arr = results.map!(res_ => res_.toJson).array;

      auto resp = Json.emptyObject
        .set("results", arr)
        .set("totalCount", Json(results.length))
        .set("message", "Validation results retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto recordId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.getResultByRecord(tenantId, recordId);
      if (result is null) {
        writeError(res, 404, "Validation result not found");
        return;
      }
      res.writeJsonBody(result.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeResult(const ValidationResult r) {
    auto j = Json.emptyObject
      .set("recordId", r.recordId)
      .set("tenantId", r.tenantId)
      .set("datasetId", r.datasetId)
      .set("totalRulesChecked", r.totalRulesChecked)
      .set("passedRules", r.passedRules)
      .set("failedRules", r.failedRules)
      .set("qualityScore", r.qualityScore)
      .set("validatedAt", r.validatedAt);

    if (r.violations.length > 0) {
      auto violations = Json.emptyArray;
      foreach (v; r.violations) {
        auto vj = Json.emptyObject
          .set("ruleId", v.ruleId)
          .set("ruleName", v.ruleName)
          .set("fieldName", v.fieldName)
          .set("fieldValue", v.fieldValue)
          .set("severity", v.severity.to!string)
          .set("message", v.message);

        if (v.suggestedValue.length > 0)
          vj = vj.set("suggestedValue", v.suggestedValue);

        violations ~= vj;
      }
      j["violations"] = violations;
    }

    return j;
  }
}
