module uim.platform.data_attribute_recommendation.domain.ports.inference_result_repository;

import uim.platform.data_attribute_recommendation.domain.types;
import uim.platform.data_attribute_recommendation.domain.entities.inference_result;

interface InferenceResultRepository
{
  InferenceResult* findById(InferenceResultId id, TenantId tenantId);
  InferenceResult* findByRequest(InferenceRequestId requestId, TenantId tenantId);
  InferenceResult[] findByTenant(TenantId tenantId);
  void save(InferenceResult result);
  void remove(InferenceResultId id, TenantId tenantId);
}
