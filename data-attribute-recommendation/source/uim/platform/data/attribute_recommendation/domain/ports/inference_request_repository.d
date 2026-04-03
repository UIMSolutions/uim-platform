module uim.platform.data.attribute_recommendation.domain.ports.inference_request_repository;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.inference_request;

interface InferenceRequestRepository
{
  InferenceRequest[] findByTenant(TenantId tenantId);
  InferenceRequest* findById(InferenceRequestId id, TenantId tenantId);
  InferenceRequest[] findByDeployment(DeploymentId deploymentId, TenantId tenantId);
  InferenceRequest[] findByStatus(TenantId tenantId, InferenceStatus status);
  void save(InferenceRequest request);
  void update(InferenceRequest request);
  void remove(InferenceRequestId id, TenantId tenantId);
}
