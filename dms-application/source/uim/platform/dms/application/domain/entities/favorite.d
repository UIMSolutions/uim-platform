module uim.platform.dms.application.domain.entities.favorite;

import uim.platform.dms.application.domain.types;

class Favorite {
  FavoriteId id;
  TenantId tenantId;
  UserId userId;
  string resourceId; // documentId or folderId
  ResourceType resourceType;
  long createdAt;
}
