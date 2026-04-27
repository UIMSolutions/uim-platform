module uim.platform.foundry.application.dto.space;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateSpaceRequest {
  OrgId orgId;
  TenantId tenantId;
  string name;
  bool allowSsh;
  string createdBy;
}

struct UpdateSpaceRequest {
  SpaceId id;
  TenantId tenantId;
  string name;
  SpaceStatus status;
  bool allowSsh;
}
