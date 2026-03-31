module domain.ports.favorite_repository;

import domain.entities.favorite;
import domain.types;

interface IFavoriteRepository
{
  Favorite[] findByTenant(TenantId tenantId);
  Favorite findById(FavoriteId id, TenantId tenantId);
  Favorite[] findByUser(UserId userId, TenantId tenantId);
  Favorite findByUserAndResource(UserId userId, string resourceId, TenantId tenantId);
  void save(Favorite fav);
  void remove(FavoriteId id, TenantId tenantId);
  void removeByResource(string resourceId, TenantId tenantId);
}
