module uim.platform.portal.domain.enumerations;

import uim.platform.portal;

mixin(ShowModule!());

@safe:


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
