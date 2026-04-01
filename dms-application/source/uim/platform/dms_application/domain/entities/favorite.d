module domain.entities.favorite;

import domain.types;

class Favorite
{
  FavoriteId id;
  TenantId tenantId;
  UserId userId;
  string resourceId; // documentId or folderId
  ResourceType resourceType;
  long createdAt;
}
