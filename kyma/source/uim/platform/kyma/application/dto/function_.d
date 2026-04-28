module uim.platform.kyma.application.dto.function_;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
struct CreateFunctionRequest {
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string runtime; // "nodejs18", "nodejs20", "python39", "python312"
  string sourceCode;
  string handler;
  string dependencies;
  string scalingType; // "fixed", "auto"
  int minReplicas;
  int maxReplicas;
  string cpuRequest;
  string cpuLimit;
  string memoryRequest;
  string memoryLimit;
  string[string] envVars;
  string[string] labels;
  int timeoutSeconds;
  UserId createdBy;
}

struct UpdateFunctionRequest {
  string description;
  string sourceCode;
  string handler;
  string dependencies;
  string scalingType;
  int minReplicas;
  int maxReplicas;
  string cpuRequest;
  string cpuLimit;
  string memoryRequest;
  string memoryLimit;
  string[string] envVars;
  string[string] labels;
  int timeoutSeconds;
}
