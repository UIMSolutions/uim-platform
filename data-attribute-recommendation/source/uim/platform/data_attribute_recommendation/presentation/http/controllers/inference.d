/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers
  .inference;

// 
// 
// import uim.platform.data_attribute_recommendation.application.usecases.process_inference;
// import uim.platform.data_attribute_recommendation.application.dto;
// import uim.platform.data_attribute_recommendation.domain.entities.inference_request;
// import uim.platform.data_attribute_recommendation.domain.entities.inference_result;
// import uim.platform.data_attribute_recommendation.domain.types;
import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());
@safe:
class InferenceController : PlatformController {
  private ProcessInferenceUseCase usecase;

  this(ProcessInferenceUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/inference", &handleSubmit);
    router.get("/api/v1/inference/results/*", &handleGetResult);
    router.get("/api/v1/inference/*", &handleGetRequest);
    router.get("/api/v1/inference", &handleListRequests);
  }

  protected Json submitHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = SubmitInferenceRequest();
    r.tenantId = tenantId;
    r.deploymentId = data.getString("deploymentId");
    r.inputData = data.getString("inputData");

    auto result = usecase.submitInference(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Inference submitted successfully", 201, responseData);
  }

  protected void handleSubmit(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = submitHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json requestHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = InferenceRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid inference request ID", 400);

    auto request = usecase.getRequest(tenantId, id);
    if (request.isNull)
      return errorResponse("Inference request not found", 404);

    auto responseData = request.toJson;
    return successResponse("Inference request retrieved successfully", 200, responseData);
  }

  protected void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = requestHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json resultHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = InferenceResultId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid inference result ID", 400);

    auto result = usecase.getResult(tenantId, id);
    if (item.isNull)
      return errorResponse("Inference result not found", 404);

    auto responseData = result.toJson;
    return successResponse("Inference result retrieved successfully", 200, responseData);
  }

  protected void handleResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = resultHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json listRequestsHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listRequests(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Inference requests retrieved successfully", 200, responseData);
  }

  protected void handleListRequests(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listRequestsHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
