/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.services.inference_engine;


// import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;
// import uim.platform.data_attribute_recommendation.domain.entities.inference_request;
// import uim.platform.data_attribute_recommendation.domain.entities.inference_result;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.deployments;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.inference_requests;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.inference_results;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:/// Domain service that processes inference requests against deployed
/// models. Validates deployment state and generates simulated predictions.
class InferenceEngine {
  private DeploymentRepository deploymentRepo;
  private InferenceRequestRepository requestRepo;
  private InferenceResultRepository resultRepo;

  this(DeploymentRepository deploymentRepo,
      InferenceRequestRepository requestRepo, InferenceResultRepository resultRepo) {
    this.deploymentRepo = deploymentRepo;
    this.requestRepo = requestRepo;
    this.resultRepo = resultRepo;
  }

  /// Check whether a deployment is available for inference.
  bool isDeploymentReady(TenantId tenantId, DeploymentId deploymentId) {
    auto dep = deploymentRepo.findById(tenantId, deploymentId);
    if (dep.isNull)
      return false;
    return dep.status == DeploymentStatus.active;
  }

  /// Process an inference request: validate, run prediction, store result.
  InferenceResult predict(TenantId tenantId, InferenceRequestId requestId) {
    auto request = requestRepo.findById(tenantId, requestId);
    if (request.isNull)
      return null;

    if (!isDeploymentReady(tenantId, request.deploymentId)) {
      request.status = InferenceStatus.failed;
      requestRepo.update(request);
      return InferenceResult.init; // Or throw an exception depending on error handling strategy
    }

    auto now = currentTimestamp();

    // Mark request as processing
    request.status = InferenceStatus.processing;
    requestRepo.update(request);

    // Simulate prediction
    InferenceResult result;
    result.initEntity(tenantId, request.createdBy);

    result.requestId = request.id;
    result.predictions = `{"category":"Electronics","subcategory":"Smartphones","brand":"Generic"}`;
    result.confidenceScores = `{"category":0.95,"subcategory":0.87,"brand":0.72}`;
    result.processingTimeMs = 42;

    resultRepo.save(result);
    // Mark request as completed
    request.status = InferenceStatus.completed;
    requestRepo.update(request);

    return resultRepo.findById(tenantId, result.id);
  }
}
