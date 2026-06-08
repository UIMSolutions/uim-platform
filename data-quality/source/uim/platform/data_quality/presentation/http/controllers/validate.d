/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.validate;

import uim.platform.service;
import uim.platform.data_quality;
import uim.platform.data_quality.application.dto;
import uim.platform.data_quality.application.usecases.validate_data;

// mixin(ShowModule!());

@safe:
class ValidateController : HttpController {
  private ValidateDataUseCase usecase;

  this(ValidateDataUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/validate", &handleValidate);
    router.post("/api/v1/validate/batch", &handleValidateBatch);
    router.get("/api/v1/validate/results/*", &handleGetResult);
  }

  protected Json validateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = ValidateRecordRequest();
    r.tenantId = tenantId;
    r.datasetId = data.getString("datasetId");
    r.recordId = data.getString("recordId");
    r.fieldValues = data.jsonStrMap("fieldValues");

    auto result = usecase.validateRecord(r);
    if (result.isNull)
      return errorResponse("Failed to validate record", 500);

    return successResponse("Record validated successfully", 200, result.toJson);
  }

  protected void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = validateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json validateBatchHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = ValidateBatchRequest();
    r.tenantId = tenantId;
    r.datasetId = data.getString("datasetId");

    foreach (item; data.getArray("records")) {
      if (item.isObject) {
        RecordFieldValues rfv;
        rfv.recordId = item.getString("recordId");
        rfv.fieldValues = jsonStrMap(item, "fieldValues");
        r.records ~= rfv;
      }
    }

    auto results = usecase.validateBatch(r);
    if (results is null)
      return errorResponse("Failed to validate batch", 500);

    auto arr = results.map!(res_ => res_.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("results", arr)
      .set("totalCount", Json(results.length))
      .set("message", "Validation results retrieved successfully");

    return successResponse("Validation completed successfully", 200, resp);
  }

  protected void handleValidateBatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = validateBatchHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json getResultHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto recordId = precheck.id;

    auto result = usecase.getResultByRecord(tenantId, recordId);
    if (result.isNull)
      return errorResponse("Validation result not found", 404);

    return successResponse("Validation result retrieved successfully", 200, result.toJson);
  }

  protected void handleGetResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = getResultHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
