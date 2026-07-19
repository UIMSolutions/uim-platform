/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.favorites;
// import uim.platform.dms.application.domain.entities.favorite;
// import uim.platform.dms.application.domain.ports.repositories.favorites;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;
mixin(ShowModule!());
@safe:

class MemoryFavoriteRepository : TenantRepository!(Favorite, FavoriteId), IFavoriteRepository {
  bool existsByUserAndResource(TenantId tenantId, UserId userId, string resourceId) {
    foreach (e; findByTenant(tenantId))
      if (e.userId == userId && e.resourceId == resourceId)
        return true;
    return false;
  }

  Favorite findByUserAndResource(TenantId tenantId, UserId userId, string resourceId) {
    foreach (e; findByTenant(tenantId))
      if (e.userId == userId && e.resourceId == resourceId)
        return e;
    return Favorite.init;
  }

  void removeByUserAndResource(TenantId tenantId, UserId userId, string resourceId) {
    foreach (e; findByTenant(tenantId))
      if (e.userId == userId && e.resourceId == resourceId) {
        remove(e);
        return;
      }
  }

  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).length;
  }

  Favorite[] filterByUser(Favorite[] favorites, UserId userId) {
    return favorites.filter!(e => e.userId == userId).array;
  }

  Favorite[] findByUser(TenantId tenantId, UserId userId) {
    return filterByUser(findByTenant(tenantId), userId);
  }

  void removeByUser(TenantId tenantId, UserId userId) {
    findByUser(tenantId, userId).each!(e => remove(e));
  }

  size_t countByResource(TenantId tenantId, string resourceId) {
    return findByResource(tenantId, resourceId).length;
  }

  Favorite[] filterByResource(Favorite[] favorites, string resourceId) {
    return favorites.filter!(e => e.resourceId == resourceId).array;
  }

  Favorite[] findByResource(TenantId tenantId, string resourceId) {
    return filterByResource(findByTenant(tenantId), resourceId);
  }

  void removeByResource(TenantId tenantId, string resourceId) {
    findByResource(tenantId, resourceId).each!(e => remove(e));
  }
}
