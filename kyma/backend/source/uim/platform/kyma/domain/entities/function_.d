/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.function_;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// A serverless function (serverless.kyma-project.io Function) in a namespace.
struct ServerlessFunction {
  mixin TenantEntity!ServerlessFunctionId;

  KymaEnvironmentId environmentId;
  NamespaceId namespaceId;
  string namespaceName;
  string name;
  string description;
  FunctionRuntime runtime = FunctionRuntime.nodejs20;
  FunctionStatus status = FunctionStatus.building;

  // Source
  string sourceCode;
  string handler = "main";
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

  KeyValue[] envVars;
  KeyValue[] labels;
  int timeoutSeconds = 180;

  /// Cluster-internal URL of the function service.
  string internalUrl() const {
    return "http://" ~ name ~ "." ~ namespaceName ~ ".svc.cluster.local";
  }
}
