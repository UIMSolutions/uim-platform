/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.serverless_function;

// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// A serverless function deployed in a Kyma namespace.
struct ServerlessFunction {
  TenantId tenantId;
  ServerlessFunction id;
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  string name;
  string description;
  FunctionRuntime runtime = FunctionRuntime.nodejs20;
  FunctionStatus status = FunctionStatus.building;

  // Source code
  string sourceCode;
  string handler;
  string dependencies;

  // Scaling
  ScalingType scalingType = ScalingType.auto_;
  int minReplicas = 1;
  int maxReplicas = 5;

  // Resources
  string cpuRequest;
  string cpuLimit;
  string memoryRequest;
  string memoryLimit;

  // Environment variables
  string[string] envVars;

  // Labels
  string[string] labels;

  // Timeout in seconds
  int timeoutSeconds = 180;

  // Metadata
  string createdBy;
  long createdAt;
  long modifiedAt;
}
