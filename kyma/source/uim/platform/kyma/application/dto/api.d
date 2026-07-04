module uim.platform.kyma.application.dto.api;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
struct CreateApiRuleRequest {
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  string serviceName;
  int servicePort;
  string gateway;
  string host;
  ApiRuleEntryDto[] rules;
  bool tlsEnabled;
  string tlsSecretName;
  bool corsEnabled;
  string[] corsAllowOrigins;
  string[] corsAllowMethods;
  string[] corsAllowHeaders;
  string[string] labels;
  UserId createdBy;
}

struct UpdateApiRuleRequest {
  string description;
  string serviceName;
  int servicePort;
  string host;
  ApiRuleEntryDto[] rules;
  bool tlsEnabled;
  string tlsSecretName;
  bool corsEnabled;
  string[] corsAllowOrigins;
  string[] corsAllowMethods;
  string[] corsAllowHeaders;
  string[string] labels;
}

struct ApiRuleEntryDto {
  string path;
  string[] methods;
  string accessStrategy;
  string[] requiredScopes;
  string[] audiences;
  string[] trustedIssuers;
}