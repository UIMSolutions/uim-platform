module uim.platform.kyma.application.dto.service_binding;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
struct CreateServiceBindingRequest {
  ServiceInstanceId serviceInstanceId;
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string secretName;
  string secretNamespace;
  string parametersJson;
  string[string] labels;
  UserId createdBy;
}

struct UpdateServiceBindingRequest {
  string description;
  string secretName;
  string parametersJson;
  string[string] labels;
}