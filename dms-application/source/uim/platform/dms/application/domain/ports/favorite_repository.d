/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositories.favorites;

// import uim.platform.dms.application.domain.entities.favorite;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IFavoriteRepository {
  Favorite[] findByTenant(TenantId tenantId);
  Favorite findById(FavoriteId id, TenantId tenantId);
  Favorite[] findByUser(UserId userId, TenantId tenantId);
  Favorite findByUserAndResource(UserId userId, string resourceId, TenantId tenantId);
  void save(Favorite fav);
  void remove(FavoriteId id, TenantId tenantId);
  void removeByResource(string resourceId, TenantId tenantId);
}
