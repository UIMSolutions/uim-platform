module uim.platform.kyma.application.dto.environment;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
struct CreateEnvironmentRequest {
  TenantId tenantId;
  SubaccountId subaccountId;
  string name;
  string description;
  string plan; // "azure", "aws", "gcp", "free", "trial"
  string region;
  int machineCount;
  string machineType;
  int autoScalerMin;
  int autoScalerMax;
  string oidcIssuerUrl;
  string oidcClientId;
  string[] oidcGroupsClaim;
  string[] oidcUsernameClaim;
  string[] administrators;
  UserId createdBy;
}

struct UpdateEnvironmentRequest {
  string name;
  string description;
  int machineCount;
  string machineType;
  int autoScalerMin;
  int autoScalerMax;
  string oidcIssuerUrl;
  string oidcClientId;
  string[] administrators;
}