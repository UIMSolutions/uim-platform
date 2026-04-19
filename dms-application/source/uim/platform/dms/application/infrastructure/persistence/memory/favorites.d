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
    return null;
  }

  void removeByUserAndResource(TenantId tenantId, UserId userId, string resourceId) {
    foreach (e; findByTenant(tenantId))
      if (e.userId == userId && e.resourceId == resourceId)
        store.remove(e.id);
  }

  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(e => e.userId == userId).length;
  }

  Favorite[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(e => e.userId == userId).array;
  }

  void removeByUser(TenantId tenantId, UserId userId) {
    findByTenant(tenantId).filter!(e => e.userId == userId).each!(e => store.remove(e.id));
  }

  size_t countByResource(TenantId tenantId, string resourceId) {
    return findByTenant(tenantId).filter!(e => e.resourceId == resourceId).length;
  }

  Favorite[] findByResource(TenantId tenantId, string resourceId) {
    return findByTenant(tenantId).filter!(e => e.resourceId == resourceId).array;
  }

  void removeByResource(TenantId tenantId, string resourceId) {
    findByTenant(tenantId).filter!(e => e.resourceId == resourceId).each!(e => store.remove(e.id));
  }
}
