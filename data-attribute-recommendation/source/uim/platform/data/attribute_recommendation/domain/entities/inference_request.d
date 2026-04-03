/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.entities.inference_request;

import uim.platform.data.attribute_recommendation.domain.types;

/// A request to predict/recommend attributes for input data
/// using a deployed model.
struct InferenceRequest
{
  InferenceRequestId id;
  TenantId tenantId;
  DeploymentId deploymentId;
  string inputData; // JSON: input attribute key-value pairs
  InferenceStatus status = InferenceStatus.pending;
  long createdAt;
}
