module domain.ports.inference_request_repository;

import domain.types;
import domain.entities.inference_request;

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
