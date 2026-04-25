/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.inference_requests;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.inference_request;

interface InferenceRequestRepository : ITenantRepository!(InferenceRequest, InferenceRequestId) {

  size_t countByDeployment(TenantId tenantId, DeploymentId deploymentId);
  InferenceRequest[] filterByDeployment(InferenceRequest[] requests, DeploymentId deploymentId);
  InferenceRequest[] findByDeployment(DeploymentId deploymenttenantId, id tenantId);
  void removeByDeployment(TenantId tenantId, DeploymentId deploymentId);

  size_t countByStatus(TenantId tenantId, InferenceStatus status);
  InferenceRequest[] filterByStatus(InferenceRequest[] requests, InferenceStatus status);
  InferenceRequest[] findByStatus(TenantId tenantId, InferenceStatus status);
  void removeByStatus(TenantId tenantId, InferenceStatus status);

}
