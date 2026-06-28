/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence.memory.inference_requests;


// import uim.platform.data_attribute_recommendation.domain.entities.inference_request;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.inference_requests;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
class MemoryInferenceRequestRepository : TenantRepository!(InferenceRequest, InferenceRequestId), InferenceRequestRepository {
  
  // #region ByDeployment
  size_t countByDeployment(TenantId tenantId, DeploymentId deploymentId) {
    return findByDeployment(tenantId, deploymentId).length;
  }
  InferenceRequest[] filterByDeployment(InferenceRequest[] requests, DeploymentId deploymentId) {
    return requests.filter!(e => e.deploymentId == deploymentId).array;
  }
  InferenceRequest[] findByDeployment(TenantId tenantId, DeploymentId deploymentId) {
    return filterByDeployment(find(tenantId), deploymentId);
  }
  void removeByDeployment(TenantId tenantId, DeploymentId deploymentId) {
    findByDeployment(tenantId, deploymentId).each!(e => remove(e));
  }
  // #endregion ByDeployment

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, InferenceStatus status) {
    return findByStatus(tenantId, status).length;
  }
  InferenceRequest[] filterByStatus(InferenceRequest[] requests, InferenceStatus status) {
    return requests.filter!(e => e.status == status).array;
  } 

  InferenceRequest[] findByStatus(TenantId tenantId, InferenceStatus status) {
    return filterByStatus(find(tenantId), status);
  } 
  void removeByStatus(TenantId tenantId, InferenceStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
  // #endregion ByStatus

}
