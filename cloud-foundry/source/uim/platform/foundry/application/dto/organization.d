module uim.platform.foundry.application.dto.organization;
 import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateOrgRequest {
  TenantId tenantId;
  string name;
  int memoryQuotaMb;
  int instanceMemoryLimitMb;
  int totalRoutes;
  int totalServices;
  int totalAppInstances;
  string createdBy;
}

struct UpdateOrgRequest {
  OrgId id;
  TenantId tenantId;
  string name;
  OrgStatus status;
  int memoryQuotaMb;
  int instanceMemoryLimitMb;
  int totalRoutes;
  int totalServices;
  int totalAppInstances;
}
