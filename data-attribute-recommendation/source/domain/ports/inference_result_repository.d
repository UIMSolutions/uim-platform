module domain.ports.inference_result_repository;

import domain.types;
import domain.entities.inference_result;

interface InferenceResultRepository
{
  InferenceResult* findById(InferenceResultId id, TenantId tenantId);
  InferenceResult* findByRequest(InferenceRequestId requestId, TenantId tenantId);
  InferenceResult[] findByTenant(TenantId tenantId);
  void save(InferenceResult result);
  void remove(InferenceResultId id, TenantId tenantId);
}
