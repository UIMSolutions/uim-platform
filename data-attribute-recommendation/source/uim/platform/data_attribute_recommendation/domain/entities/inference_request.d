module uim.platform.data_attribute_recommendation.domain.entities.inference_request;

import uim.platform.data_attribute_recommendation.domain.types;

/// A request to predict/recommend attributes for input data
/// using a deployed model.
struct InferenceRequest
{
  InferenceRequestId id;
  TenantId tenantId;
  DeploymentId deploymentId;
  string inputData;   // JSON: input attribute key-value pairs
  InferenceStatus status = InferenceStatus.pending;
  long createdAt;
}
