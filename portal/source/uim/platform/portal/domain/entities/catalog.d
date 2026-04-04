/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.catalog;

// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Content catalog — groups tiles for content administration.
struct Catalog {
  CatalogId id;
  TenantId tenantId;
  string title;
  string description;
  ProviderId providerId;
  TileId[] tileIds;
  RoleId[] allowedRoleIds;
  bool active = true;
  long createdAt;
  long updatedAt;
}
