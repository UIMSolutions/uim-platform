/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.validate;





// import uim.platform.data_quality.application.usecases.validate_data;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.validation_result;
import uim.platform.data_quality;

mixin(ShowModule!());

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

  protected void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = ValidateRecordRequest();
      r.tenantId = precheck.tenantId;
      r.datasetId = data.getString("datasetId");
      r.recordId = data.getString("recordId");
      r.fieldValues = data.jsonStrMap("fieldValues");

      auto result = usecase.validateRecord(r);
      res.writeJsonBody(result.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleValidateBatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = ValidateBatchRequest();
      r.tenantId = precheck.tenantId;
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
      auto arr = results.map!(res_ => res_.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("results", arr)
        .set("totalCount", Json(results.length))
        .set("message", "Validation results retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGetResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto recordId = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.getResultByRecord(tenantId, recordId);
      if (result.isNull) {
        writeError(res, 404, "Validation result not found");
        return;
      }
      res.writeJsonBody(result.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
