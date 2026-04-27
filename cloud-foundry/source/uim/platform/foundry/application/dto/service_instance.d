module uim.platform.foundry.application.dto.service_instance;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateServiceInstanceRequest {
  SpaceId spaceId;
  TenantId tenantId;
  string name;
  string serviceName;
  string servicePlanName;
  string parameters;
  string tags;
  string createdBy;
}

struct UpdateServiceInstanceRequest {
  ServiceInstanceId id;
  TenantId tenantId;
  string name;
  string servicePlanName;
  string parameters;
  string tags;
}
