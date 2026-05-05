/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.entities.inference_result;

import uim.platform.data.attribute_recommendation.domain.types;

/// The predicted attributes and confidence scores returned
/// by the inference engine for a given request.
struct InferenceResult {
  mixin TenantEntity!InferenceResultId;

  InferenceRequestId requestId;
  string predictions; // JSON: {attributeName: predictedValue, ...}
  string confidenceScores; // JSON: {attributeName: score, ...}
  long processingTimeMs;
  
  Json toJson() const {
    return entityToJson
      .set("requestId", requestId)
      .set("predictions", predictions)
      .set("confidenceScores", confidenceScores)
      .set("processingTimeMs", processingTimeMs);
  }
}
