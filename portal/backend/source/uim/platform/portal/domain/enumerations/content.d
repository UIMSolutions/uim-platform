/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.enumerations.content;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Visual type of a tile.
enum TileType {
  static_, /// simple launcher
  dynamic, /// shows a number read from a service
  custom, /// custom widget
  news, /// news / feed tile
  kpi, /// KPI with target and indicator
}

/// Technology of the launched application.
enum AppType {
  sapui5,
  webDynpro,
  sapGuiHtml,
  url,
  webComponent,
  native,
}

/// Semantic colour of a KPI tile.
enum IndicatorColor {
  neutral,
  positive,
  critical,
  negative,
}

/// Size of a tile on a page.
enum TileSize {
  responsive,
  small,
  wide,
}

/// Where the content of a provider comes from.
enum ProviderType {
  local, /// maintained in this portal
  remote, /// exposed by a remote content endpoint (HTML5 repository, Work Zone content)
  federated, /// federated from another launchpad
}

/// Health of a content provider.
enum ProviderStatus {
  active,
  inactive,
  syncError,
}

///
unittest {
  assert(enumText(TileType.static_) == "static");
  assert(parseEnum!TileType("static", TileType.kpi) == TileType.static_);
  assert(parseEnum!ProviderStatus("sync-error", ProviderStatus.active) == ProviderStatus.syncError);
}
