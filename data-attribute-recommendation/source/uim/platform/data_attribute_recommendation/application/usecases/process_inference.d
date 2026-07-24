/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.application.usecases.process_inference;

// import uim.platform.data_attribute_recommendation.domain.entities.inference_request;
// import uim.platform.data_attribute_recommendation.domain.entities.inference_result;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.inference_requests;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.inference_results;
// import uim.platform.data_attribute_recommendation.domain.services.inference_engine;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
class ProcessInferenceUseCase { // TODO: UIMUseCase {
  private IInferenceRequestRepository requestRepo;
  private IInferenceResultRepository resultRepo;
  private InferenceEngine engine;

  this(IInferenceRequestRepository requestRepo,
    IInferenceResultRepository resultRepo, InferenceEngine engine) {
    this.requestRepo = requestRepo;
    this.resultRepo = resultRepo;
    this.engine = engine;
  }

  /// Submit an inference request and get immediate prediction.
  CommandResult submitInference(SubmitInferenceRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.deploymentId.isEmpty)
      return CommandResult(false, "", "Deployment ID is required");
    if (req.inputData.length == 0)
      return CommandResult(false, "", "Input data is required");

    if (!engine.isDeploymentReady(req.tenantId, req.deploymentId))
      return CommandResult(false, "", "Deployment is not active");

    auto request = InferenceRequest(req.tenantId);
    // request.createdBy = req.createdBy;
    request.deploymentId = req.deploymentId;
    request.inputData = req.inputData;
    request.status = InferenceStatus.pending;

    requestRepo.save(request);
    // Process immediately
    auto result = engine.predict(req.tenantId, request.id);
    if (result.isNull)
      return CommandResult(false, "", "Inference processing failed");

    return CommandResult(true, result.id.value, "");
  }

  InferenceResult getInferenceResult(TenantId tenantId, InferenceResultId id) {
    return resultRepo.findById(tenantId, id);
  }

  InferenceResult getInferenceResult(TenantId tenantId, InferenceRequestId requestId) {
    return resultRepo.findByRequest(tenantId, requestId);
  }

  InferenceRequest getInferenceRequest(TenantId tenantId, InferenceRequestId requestId) {
    return requestRepo.findById(tenantId, requestId);
  }

  InferenceRequest[] listInferenceRequests(TenantId tenantId) {
    return requestRepo.findByTenant(tenantId);
  }

  InferenceRequest[] listInferenceRequests(TenantId tenantId, DeploymentId deploymentId) {
    return requestRepo.findByDeployment(tenantId, deploymentId);
  }
}
