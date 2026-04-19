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
interface IFavoriteRepository : ITenantRepository!(Favorite, FavoriteId) {
  size_t countByUser(TenantId tenantId, UserId userId);
  Favorite[] findByUser(TenantId tenantId, UserId userId);
  void removeByUser(TenantId tenantId, UserId userId);
  
  Favorite findByUserAndResource(TenantId tenantId, UserId userId, string resource);

  void save(Favorite fav);
  void removeByResource(TenantId tenantId, string resource);
}
