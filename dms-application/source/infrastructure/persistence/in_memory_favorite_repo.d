module infrastructure.persistence.in_memory_favorite_repo;

import domain.entities.favorite;
import domain.ports.favorite_repository;
import domain.types;

class InMemoryFavoriteRepository : IFavoriteRepository
{
  private Favorite[string] store;

  Favorite[] findByTenant(TenantId tenantId)
  {
    Favorite[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Favorite findById(FavoriteId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Favorite[] findByUser(UserId userId, TenantId tenantId)
  {
    Favorite[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.userId == userId)
        result ~= e;
    return result;
  }

  Favorite findByUserAndResource(UserId userId, string resourceId, TenantId tenantId)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.userId == userId && e.resourceId == resourceId)
        return e;
    return null;
  }

  void save(Favorite fav) { store[fav.id] = fav; }
  void remove(FavoriteId id, TenantId tenantId) { store.remove(id); }

  void removeByResource(string resourceId, TenantId tenantId)
  {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.resourceId == resourceId)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
