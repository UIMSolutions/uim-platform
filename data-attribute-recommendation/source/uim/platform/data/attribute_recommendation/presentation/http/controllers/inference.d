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
        auto resp = Json.emptyObject;
        resp["resultId"] = Json(result.id);
        resp["status"] = Json("completed");
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
        auto arr = Json.emptyArray;
        foreach (r; requests)
          arr ~= serializeRequest(r);

        auto resp = Json.emptyObject;
        resp["items"] = arr;
        resp["totalCount"] = Json(requests.length);
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

      auto arr = Json.emptyArray;
      foreach (r; items)
        arr ~= serializeRequest(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeRequest(const InferenceRequest r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["deploymentId"] = Json(r.deploymentId);
    j["inputData"] = Json(r.inputData);
    j["status"] = Json(r.status.to!string);
    j["createdAt"] = Json(r.createdAt);
    return j;
  }

  private static Json serializeResult(const InferenceResult r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["requestId"] = Json(r.requestId);
    j["predictions"] = Json(r.predictions);
    j["confidenceScores"] = Json(r.confidenceScores);
    j["processingTimeMs"] = Json(r.processingTimeMs);
    j["createdAt"] = Json(r.createdAt);
    return j;
  }
}
