/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.ports.inference_results;

// import uim.platform.data_attribute_recommendation.domain.types;
// import uim.platform.data_attribute_recommendation.domain.entities.inference_result;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
interface InferenceResultRepository : ITenantRepository!(InferenceResult, InferenceResultId) {

  size_t countByPredictions(TenantId tenantId, string predictions);
  InferenceResult[] findByPredictions(TenantId tenantId, string predictions);
  void removeByPredictions(TenantId tenantId, string predictions);

  bool existsByRequest(TenantId tenantId, InferenceRequestId requestId);
  InferenceResult findByRequest(TenantId tenantId, InferenceRequestId requestId);
  void removeByRequest(TenantId tenantId, InferenceRequestId requestId);

}
