module uim.platform.kyma.application.dto.module_;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
struct EnableModuleRequest {
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string moduleType; // "istio", "serverless", "eventing", etc.
  string version_;
  string channel;
  string customResourcePolicy;
  string configurationJson;
  string enabledBy;
}

struct UpdateModuleRequest {
  string version_;
  string channel;
  string customResourcePolicy;
  string configurationJson;
}