module uim.platform.foundry.domain.entities.space;

import uim.platform.foundry.domain.types;

/// A space — an isolated area within an organization where applications,
/// services, and routes are deployed and managed.
struct Space {
  SpaceId id;
  OrgId orgId;
  TenantId tenantId;
  string name;
  SpaceStatus status = SpaceStatus.active;
  bool allowSsh = true;
  string createdBy;
  long createdAt;
  long updatedAt;
}
