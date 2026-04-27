module uim.platform.foundry.application.dto.service_binding;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateServiceBindingRequest {
  AppId appId;
  ServiceInstanceId serviceInstanceId;
  TenantId tenantId;
  string name;
  string bindingOptions;
  string createdBy;
}
