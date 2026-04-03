module uim.platform.data.attribute_recommendation.domain.entities.inference_result;

import uim.platform.data.attribute_recommendation.domain.types;

/// The predicted attributes and confidence scores returned
/// by the inference engine for a given request.
struct InferenceResult
{
  InferenceResultId id;
  TenantId tenantId;
  InferenceRequestId requestId;
  string predictions;      // JSON: {attributeName: predictedValue, ...}
  string confidenceScores; // JSON: {attributeName: score, ...}
  long processingTimeMs;
  long createdAt;
}
