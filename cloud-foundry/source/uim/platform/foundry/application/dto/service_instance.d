module uim.platform.foundry.application.dto.service_instance;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateServiceInstanceRequest {
  ServiceInstanceId instanceId;
  SpaceId spaceId;
  TenantId tenantId;
  
  string name;
  string serviceName;
  string servicePlanName;
  string parameters;
  string tags;
  UserId createdBy;
}

struct UpdateServiceInstanceRequest {
  ServiceInstanceId instanceId;
  TenantId tenantId;
  string name;
  string servicePlanName;
  string parameters;
  string tags;
}
