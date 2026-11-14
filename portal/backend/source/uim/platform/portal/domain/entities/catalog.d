/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.catalog;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A content catalog — groups tiles for administration and role assignment.
struct PortalCatalog {
  mixin TenantEntity!CatalogId;

  /// The provider the content comes from (empty = local content).
  ContentProviderId providerId;
  string name;
  string description;
  PortalRoleId[] allowedRoleIds;
  bool active = true;
  /// Number of tiles (maintained by the tile interactor).
  int tileCount;
}
