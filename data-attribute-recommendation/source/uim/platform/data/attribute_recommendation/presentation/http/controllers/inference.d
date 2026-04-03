module uim.platform.data.attribute_recommendation.presentation.http.controllers
  .inference_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;
// 
// import uim.platform.data.attribute_recommendation.application.usecases.process_inference;
// import uim.platform.data.attribute_recommendation.application.dto;
// import uim.platform.data.attribute_recommendation.domain.entities.inference_request;
// import uim.platform.data.attribute_recommendation.domain.entities.inference_result;
// import uim.platform.data.attribute_recommendation.domain.types;
// import uim.platform.data.attribute_recommendation.presentation.http.json_utils;
import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());
@safe:
class InferenceController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.deploymentId = j.getString("deploymentId");
      r.inputData = j.getString("inputData");

      auto result = uc.submitInference(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject;
        resp["resultId"] = Json(result.id);
        resp["status"] = Json("completed");
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");

      // Try as inference request
      auto requests = uc.listByDeployment(id, tenantId);
      if (requests.length > 0) {
        auto arr = Json.emptyArray;
        foreach (ref r; requests)
          arr ~= serializeRequest(r);

        auto resp = Json.emptyObject;
        resp["items"] = arr;
        resp["totalCount"] = Json(cast(long)requests.length);
        res.writeJsonBody(resp, 200);
        return;
      }

      writeError(res, 404, "Inference request not found");
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.getResult(id, tenantId);
      if (result is null) {
        // Try by request id
        result = uc.getResultByRequest(id, tenantId);
      }
      if (result is null) {
        writeError(res, 404, "Inference result not found");
        return;
      }
      res.writeJsonBody(serializeResult(*result), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListRequests(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listRequests(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref r; items)
        arr ~= serializeRequest(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeRequest(ref const InferenceRequest r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["deploymentId"] = Json(r.deploymentId);
    j["inputData"] = Json(r.inputData);
    j["status"] = Json(r.status.to!string);
    j["createdAt"] = Json(r.createdAt);
    return j;
  }

  private static Json serializeResult(ref const InferenceResult r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["requestId"] = Json(r.requestId);
    j["predictions"] = Json(r.predictions);
    j["confidenceScores"] = Json(r.confidenceScores);
    j["processingTimeMs"] = Json(cast(long)r.processingTimeMs);
    j["createdAt"] = Json(r.createdAt);
    return j;
  }
}
