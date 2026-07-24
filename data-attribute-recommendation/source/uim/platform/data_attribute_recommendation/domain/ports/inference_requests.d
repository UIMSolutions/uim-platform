/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.ports.inference_requests;

// import uim.platform.data_attribute_recommendation.domain.entities.inference_request;
import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());

@safe:
interface IInferenceRequestRepository : ITenantRepository!(InferenceRequest, InferenceRequestId) {

  size_t countByDeployment(TenantId tenantId, DeploymentId deploymentId);
  InferenceRequest[] findByDeployment(TenantId tenantId, DeploymentId deploymentId);
  void removeByDeployment(TenantId tenantId, DeploymentId deploymentId);

  size_t countByStatus(TenantId tenantId, InferenceStatus status);
  InferenceRequest[] findByStatus(TenantId tenantId, InferenceStatus status);
  void removeByStatus(TenantId tenantId, InferenceStatus status);

}
