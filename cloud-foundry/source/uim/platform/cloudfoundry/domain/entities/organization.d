module domain.entities.organization;

import domain.types;

/// An organization — the top-level grouping for spaces, users, and quotas
/// within a Cloud Foundry environment.
struct Organization
{
  OrgId id;
  TenantId tenantId;
  string name;
  OrgStatus status = OrgStatus.active;
  int memoryQuotaMb = 10_240;         // 10 GB default org quota
  int instanceMemoryLimitMb = 2048;   // per-instance memory cap
  int totalRoutes = 1000;
  int totalServices = 100;
  int totalAppInstances = -1;         // -1 = unlimited
  string createdBy;
  long createdAt;
  long updatedAt;
}
