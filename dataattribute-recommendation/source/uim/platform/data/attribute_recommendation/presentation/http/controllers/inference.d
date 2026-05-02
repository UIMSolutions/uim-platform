/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.presentation.http.controllers
  .inference_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.data.attribute_recommendation.application.usecases.process_inference;
// import uim.platform.data.attribute_recommendation.application.dto;
// import uim.platform.data.attribute_recommendation.domain.entities.inference_request;
// import uim.platform.data.attribute_recommendation.domain.entities.inference_result;
// import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());
@safe:
class InferenceController : PlatformController {
  private ProcessInferenceUseCase uc;

  this(ProcessInferenceUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/inference", &handleSubmit);
    router.get("/api/v1/inference/results/*", &handleGetResult);
    router.get("/api/v1/inference/*", &handleGetRequest);
    router.get("/api/v1/inference", &handleListRequests);
  }

  private void handleSubmit(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = SubmitInferenceRequest();
      r.tenantId = req.getTenantId;
      r.deploymentId = j.getString("deploymentId");
      r.inputData = j.getString("inputData");

      auto result = uc.submitInference(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("resultId", Json(result.id))
            .set("status", Json("completed"))
            .set("message", "Inference submitted successfully");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;

      // Try as inference request
      auto requests = uc.listByDeployment(tenantId, id);
      if (requests.length > 0) {
        auto arr = requests.map!(r => r.toJson).array;

        auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", Json(requests.length))
            .set("message", "Inference requests retrieved successfully");

        res.writeJsonBody(resp, 200);
        return;
      }

      writeError(res, 404, "Inference request not found");
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.getResult(tenantId, id);
      if (result is null) {
        // Try by request id
        result = uc.getResultByRequest(tenantId, id);
      }
      if (result is null) {
        writeError(res, 404, "Inference result not found");
        return;
      }
      res.writeJsonBody(serializeResult(*result), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListRequests(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listRequests(tenantId);
      auto arr = items.map!(r => serializeRequest(r)).array.toJson;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", Json(items.length))
            .set("message", "Inference requests retrieved successfully");
            
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeRequest(const InferenceRequest r) {
    return Json.emptyObject
      .set("id", r.id)
      .set("tenantId", r.tenantId)
      .set("deploymentId", r.deploymentId)
      .set("inputData", r.inputData)
      .set("status", r.status.to!string)
      .set("createdAt", r.createdAt);
  }

  private static Json serializeResult(const InferenceResult r) {
    return Json.emptyObject
      .set("id", r.id)
      .set("tenantId", r.tenantId)
      .set("requestId", r.requestId)
      .set("predictions", r.predictions)
      .set("confidenceScores", r.confidenceScores)
      .set("processingTimeMs", r.processingTimeMs)
      .set("createdAt", r.createdAt);
  }
}
