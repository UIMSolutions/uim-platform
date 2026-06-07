/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.entities.inference_request;

import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
/// A request to predict/recommend attributes for input data
/// using a deployed model.
struct InferenceRequest {
  mixin TenantEntity!InferenceRequestId;

  DeploymentId deploymentId; // ID of the model deployment to use for inference
  string inputData; // JSON: input attribute key-value pairs
  InferenceStatus status = InferenceStatus.pending; // pending, running, completed, failed
  
  Json toJson() const {
    return entityToJson
      .set("deploymentId", deploymentId)
      .set("inputData", inputData)
      .set("status", status.to!string);
  }
}
