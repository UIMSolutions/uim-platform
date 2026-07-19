module uim.platform.foundry.application.dto.organization;
 import uim.platform.foundry;
mixin(ShowModule!());

@safe:

struct CreateOrgRequest {
  TenantId tenantId;
  OrgId orgId;
  
  string name;
  int memoryQuotaMb;
  int instanceMemoryLimitMb;
  int totalRoutes;
  int totalServices;
  int totalAppInstances;
  UserId createdBy;
}

struct UpdateOrgRequest {
  TenantId tenantId;
  OrgId orgId;

  string name;
  string status;
  int memoryQuotaMb;
  int instanceMemoryLimitMb;
  int totalRoutes;
  int totalServices;
  int totalAppInstances;
}
