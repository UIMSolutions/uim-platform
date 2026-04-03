/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.entities.model_deployment;

import uim.platform.data.attribute_recommendation.domain.types;

/// A deployed instance of a trained model, exposing an inference endpoint
/// for real-time attribute recommendations.
struct ModelDeployment
{
  DeploymentId id;
  TenantId tenantId;
  TrainingJobId trainingJobId;
  ModelConfigId modelConfigId;
  string name;
  DeploymentStatus status = DeploymentStatus.deploying;
  string endpointUrl;
  string version_;
  int replicas;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
