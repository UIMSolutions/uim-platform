/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.inference_result_repository;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.inference_result;

interface InferenceResultRepository
{
  InferenceResult* findById(InferenceResultId id, TenantId tenantId);
  InferenceResult* findByRequest(InferenceRequestId requestId, TenantId tenantId);
  InferenceResult[] findByTenant(TenantId tenantId);
  void save(InferenceResult result);
  void remove(InferenceResultId id, TenantId tenantId);
}
