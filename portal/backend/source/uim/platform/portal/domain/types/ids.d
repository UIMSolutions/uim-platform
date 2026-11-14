/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly typed identifiers of the portal aggregates.
module uim.platform.portal.domain.types.ids;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A portal site (launchpad).
struct SiteId {
  mixin(IdTemplate);
}

/// A page of a site.
struct PageId {
  mixin(IdTemplate);
}

/// A section of a page (groups tiles).
struct SectionId {
  mixin(IdTemplate);
}

/// A tile / app launcher of a catalog.
struct TileId {
  mixin(IdTemplate);
}

/// A content catalog.
struct CatalogId {
  mixin(IdTemplate);
}

/// A content provider (local, remote or federated source of catalogs).
struct ContentProviderId {
  mixin(IdTemplate);
}

/// A portal role (controls who sees which content).
struct PortalRoleId {
  mixin(IdTemplate);
}

/// A theme definition.
struct ThemeId {
  mixin(IdTemplate);
}

/// A navigation menu item of a site.
struct MenuItemId {
  mixin(IdTemplate);
}

/// A translation of a text field.
struct TranslationId {
  mixin(IdTemplate);
}
