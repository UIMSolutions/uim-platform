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
  mixin TenantEntity!(CatalogId);

  string title;
  string description;
  ProviderId providerId;
  TileId[] tileIds;
  RoleId[] allowedRoleIds;
  bool active = true;

  Json toJson() const {
    auto j = entityToJson
      .set("title", title)
      .set("description", description)
      .set("providerId", providerId.value)
      .set("tileIds", tileIds.map!(id => id.value).array)
      .set("allowedRoleIds", allowedRoleIds.map!(id => id.value).array)
      .set("active", active);

    return j;
  }
}
