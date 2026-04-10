/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.application.usecases.process_inference;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.inference_request;
import uim.platform.data.attribute_recommendation.domain.entities.inference_result;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.inference_requests;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.inference_results;
import uim.platform.data.attribute_recommendation.domain.services.inference_engine;
import uim.platform.data.attribute_recommendation.application.dto;

class ProcessInferenceUseCase : UIMUseCase {
  private InferenceRequestRepository requestRepo;
  private InferenceResultRepository resultRepo;
  private InferenceEngine engine;

  this(InferenceRequestRepository requestRepo,
      InferenceResultRepository resultRepo, InferenceEngine engine) {
    this.requestRepo = requestRepo;
    this.resultRepo = resultRepo;
    this.engine = engine;
  }

  /// Submit an inference request and get immediate prediction.
  CommandResult submitInference(SubmitInferenceRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.deploymentid.isEmpty)
      return CommandResult(false, "", "Deployment ID is required");
    if (req.inputData.length == 0)
      return CommandResult(false, "", "Input data is required");

    if (!engine.isDeploymentReady(req.deploymentId, req.tenantId))
      return CommandResult(false, "", "Deployment is not active");

    auto now = Clock.currStdTime();
    auto request = InferenceRequest();
    request.id = randomUUID();
    request.tenantId = req.tenantId;
    request.deploymentId = req.deploymentId;
    request.inputData = req.inputData;
    request.status = InferenceStatus.pending;
    request.createdAt = now;

    requestRepo.save(request);

    // Process immediately
    auto result = engine.predict(request.id, req.tenantId);
    if (result is null)
      return CommandResult(false, "", "Inference processing failed");

    return CommandResult(result.id, "");
  }

  InferenceResult* getResult(InferenceResultId tenantId, id tenantId) {
    return resultRepo.findById(tenantId, id);
  }

  InferenceResult* getResultByRequest(InferenceRequestId requesttenantId, id tenantId) {
    return resultRepo.findByRequest(requesttenantId, id);
  }

  InferenceRequest[] listRequests(TenantId tenantId) {
    return requestRepo.findByTenant(tenantId);
  }

  InferenceRequest[] listByDeployment(DeploymentId deploymenttenantId, id tenantId) {
    return requestRepo.findByDeployment(deploymenttenantId, id);
  }
}
