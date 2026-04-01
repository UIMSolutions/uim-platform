module  uim.platform.dms_application.domain.entities.favorite;

import uim.platform.dms_application.domain.types;

class Favorite
{
  FavoriteId id;
  TenantId tenantId;
  UserId userId;
  string resourceId; // documentId or folderId
  ResourceType resourceType;
  long createdAt;
}
