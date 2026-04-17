/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct SiteId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct PageId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct SectionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TileId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CatalogId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct GroupId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RoleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ProviderId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ThemeId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct MenuItemId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TranslationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

/// Site status.
enum SiteStatus {
  draft,
  published,
  unpublished,
  archived,
}

/// Page layout type.
enum PageLayout {
  freeform,
  anchored,
  twoColumn,
  threeColumn,
  dashboard,
}

/// Tile type (app launcher type).
enum TileType {
  static_, // simple link tile
  dynamic, // tile with dynamic data count
  custom, // custom widget tile
  news, // news/feed tile
  kpi, // KPI indicator tile
}

/// App type for tiles.
enum AppType {
  sapui5,
  webDynpro,
  sapGuiHtml,
  url,
  webComponent,
  native_,
}

/// Content provider type.
enum ProviderType {
  local,
  remote,
  federated,
}

/// Theme mode.
enum ThemeMode {
  light,
  dark,
  highContrast,
  highContrastDark,
}

/// Navigation target type.
enum NavigationTarget {
  inPlace,
  newWindow,
  embedded,
}

/// Transport status.
enum TransportStatus {
  pending,
  inProgress,
  completed,
  failed,
}

/// Role assignment scope.
enum RoleScope {
  site,
  catalog,
  group,
  page,
}
