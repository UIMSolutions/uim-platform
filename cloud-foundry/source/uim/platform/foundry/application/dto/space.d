module uim.platform.foundry.application.dto.space;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

struct CreateSpaceRequest {
  TenantId tenantId;
  SpaceId spaceId;
  OrgId orgId;

  string name;
  bool allowSsh;
  UserId createdBy;
}

struct UpdateSpaceRequest {
  SpaceId spaceId;
  TenantId tenantId;
  string name;
  SpaceStatus status;
  bool allowSsh;
}
