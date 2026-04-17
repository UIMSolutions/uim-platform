module uim.platform.kyma.application.dto.namespace;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
struct CreateNamespaceRequest {
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string cpuLimit;
  string memoryLimit;
  string cpuRequest;
  string memoryRequest;
  int podLimit;
  string quotaEnforcement;
  bool istioInjection;
  string[string] labels;
  string[string] annotations;
  string createdBy;
}

struct UpdateNamespaceRequest {
  string description;
  string cpuLimit;
  string memoryLimit;
  string cpuRequest;
  string memoryRequest;
  int podLimit;
  string quotaEnforcement;
  bool istioInjection;
  string[string] labels;
  string[string] annotations;
}