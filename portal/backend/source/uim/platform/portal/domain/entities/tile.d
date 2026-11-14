/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.tile;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A tile / app launcher. Tiles belong to a catalog and are placed on pages
/// through sections.
struct PortalTile {
  mixin TenantEntity!TileId;

  CatalogId catalogId;
  /// Title shown on the tile.
  string name;
  string subtitle;
  string description;
  string icon = "sap-icon://product";
  string info;
  TileType tileType = TileType.static_;
  AppType appType = AppType.url;
  NavigationTarget navigationTarget = NavigationTarget.inPlace;

  // Target: either a URL, or an app id (SAPUI5 component) / intent
  string url;
  string appId;
  string semanticObject;
  string action;

  string[] keywords;
  PortalRoleId[] allowedRoleIds;

  // Dynamic / KPI configuration
  string serviceUrl;
  int refreshIntervalSeconds;
  string numberUnit;
  string targetNumber;
  IndicatorColor indicatorColor = IndicatorColor.neutral;
  TileSize size = TileSize.responsive;

  int sortOrder;
  bool visible = true;

  /// The launchpad intent "#SemanticObject-action" ("" if none).
  string intent() const {
    return semanticObject.length > 0 && action.length > 0 ? "#" ~ semanticObject ~ "-" ~ action : "";
  }
}
