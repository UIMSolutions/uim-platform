/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.enumerations;

import uim.platform.portal;

// mixin(ShowModule!());

@safe:


/// Site status.
enum SiteStatus {
  draft,
  published,
  unpublished,
  archived,
}
SiteStatus toSiteStatus(string value) {
  mixin(EnumSwitch("SiteStatus", "draft"));
}
SiteStatus[] toSiteStatus(string[] values) {
  return values.map!(v => toSiteStatus(v));
}
string toString(SiteStatus status) {
  return status.to!string;
}
string[] toString(SiteStatus[] statuses) {
  return statuses.map!(s => toString(s));
}
///
unittest {
  assert(toSiteStatus("draft") == SiteStatus.draft);
  assert(toSiteStatus("published") == SiteStatus.published);
  assert(toSiteStatus("unpublished") == SiteStatus.unpublished);
  assert(toSiteStatus("archived") == SiteStatus.archived);
  assert(toSiteStatus("unknown") == SiteStatus.draft); // default to draft

  assert(toString(SiteStatus.draft) == "draft");
  assert(toString(SiteStatus.published) == "published");
  assert(toString(SiteStatus.unpublished) == "unpublished");
  assert(toString(SiteStatus.archived) == "archived");

  assert(toSiteStatus(["draft", "published", "unpublished", "archived", "unknown"]) ==
         [SiteStatus.draft, SiteStatus.published, SiteStatus.unpublished, SiteStatus.archived, SiteStatus.draft]);
  assert(toString([SiteStatus.draft, SiteStatus.published, SiteStatus.unpublished, SiteStatus.archived]) ==
         ["draft", "published", "unpublished", "archived"]);
}

/// Page layout type.
enum PageLayout {
  freeform,
  anchored,
  twoColumn,
  threeColumn,
  dashboard,
}
PageLayout toPageLayout(string value) {
  mixin(EnumSwitch("PageLayout", "freeform"));
}
PageLayout[] toPageLayout(string[] values) {
  return values.map!(v => toPageLayout(v));
}
string toString(PageLayout layout) {
  return layout.to!string;
}
string[] toString(PageLayout[] layouts) {
  return layouts.map!(l => toString(l));
}
///
unittest {
  assert(toPageLayout("freeform") == PageLayout.freeform);
  assert(toPageLayout("anchored") == PageLayout.anchored);
  assert(toPageLayout("twoColumn") == PageLayout.twoColumn);
  assert(toPageLayout("threeColumn") == PageLayout.threeColumn);
  assert(toPageLayout("dashboard") == PageLayout.dashboard);
  assert(toPageLayout("unknown") == PageLayout.freeform); // default to freeform

  assert(toString(PageLayout.freeform) == "freeform");
  assert(toString(PageLayout.anchored) == "anchored");
  assert(toString(PageLayout.twoColumn) == "twoColumn");
  assert(toString(PageLayout.threeColumn) == "threeColumn");
  assert(toString(PageLayout.dashboard) == "dashboard");

  assert(toPageLayout(["freeform", "anchored", "twoColumn", "threeColumn", "dashboard", "unknown"]) ==
         [PageLayout.freeform, PageLayout.anchored, PageLayout.twoColumn, PageLayout.threeColumn, PageLayout.dashboard, PageLayout.freeform]);
  assert(toString([PageLayout.freeform, PageLayout.anchored, PageLayout.twoColumn, PageLayout.threeColumn, PageLayout.dashboard]) ==
         ["freeform", "anchored", "twoColumn", "threeColumn", "dashboard"]);
}

/// Tile type (app launcher type).
enum TileType : string {
  static_ = "static", // simple link tile
  dynamic = "dynamic", // tile with dynamic data count
  custom = "custom", // custom widget tile
  news = "news", // news/feed tile
  kpi = "kpi", // KPI indicator tile
}
TileType toTileType(string value) {
  switch(value.toLower) {
    case "static_": return TileType.static_;
    case "dynamic": return TileType.dynamic;
    case "custom": return TileType.custom;
    case "news": return TileType.news;
    case "kpi": return TileType.kpi;
    default: return TileType.static_; // default to static_
  }
}
TileType[] toTileType(string[] values) {
  return values.map!(v => toTileType(v));
}
string toString(TileType type) {
  return cast(string)type;
}
string[] toString(TileType[] types) {
  return types.map!(t => toString(t));
}
///
unittest {
  assert(toTileType("static_") == TileType.static_);
  assert(toTileType("dynamic") == TileType.dynamic);
  assert(toTileType("custom") == TileType.custom);
  assert(toTileType("news") == TileType.news);
  assert(toTileType("kpi") == TileType.kpi);
  assert(toTileType("unknown") == TileType.static_); // default to static_

  assert(toString(TileType.static_) == "static_");
  assert(toString(TileType.dynamic) == "dynamic");
  assert(toString(TileType.custom) == "custom");
  assert(toString(TileType.news) == "news");
  assert(toString(TileType.kpi) == "kpi");

  assert(toTileType(["static_", "dynamic", "custom", "news", "kpi", "unknown"]) ==
         [TileType.static_, TileType.dynamic, TileType.custom, TileType.news, TileType.kpi, TileType.static_]);
  assert(toString([TileType.static_, TileType.dynamic, TileType.custom, TileType.news, TileType.kpi]) ==
         ["static_", "dynamic", "custom", "news", "kpi"]);
}

/// App type for tiles.
enum AppType {
  sapui5,
  webDynpro,
  sapGuiHtml,
  url,
  webComponent,
  native,
}
AppType toAppType(string value) {
  mixin(EnumSwitch("AppType", "sapui5"));
}
AppType[] toAppType(string[] values) {
  return values.map!(v => toAppType(v));
}
string toString(AppType type) {
  return type.to!string;
}
string[] toString(AppType[] types) {
  return types.map!(t => toString(t));
}
///
unittest {  
  assert(toAppType("sapui5") == AppType.sapui5);
  assert(toAppType("webDynpro") == AppType.webDynpro);
  assert(toAppType("sapGuiHtml") == AppType.sapGuiHtml);
  assert(toAppType("url") == AppType.url);
  assert(toAppType("webComponent") == AppType.webComponent);
  assert(toAppType("native") == AppType.native);
  assert(toAppType("unknown") == AppType.sapui5); // default to sapui5

  assert(toString(AppType.sapui5) == "sapui5");
  assert(toString(AppType.webDynpro) == "webDynpro");
  assert(toString(AppType.sapGuiHtml) == "sapGuiHtml");
  assert(toString(AppType.url) == "url");
  assert(toString(AppType.webComponent) == "webComponent");
  assert(toString(AppType.native) == "native");

  assert(toAppType(["sapui5", "webDynpro", "sapGuiHtml", "url", "webComponent", "native", "unknown"]) ==
         [AppType.sapui5, AppType.webDynpro, AppType.sapGuiHtml, AppType.url, AppType.webComponent, AppType.native, AppType.sapui5]);
  assert(toString([AppType.sapui5, AppType.webDynpro, AppType.sapGuiHtml, AppType.url, AppType.webComponent, AppType.native]) ==
         ["sapui5", "webDynpro", "sapGuiHtml", "url", "webComponent", "native"]);
}

/// Content provider type.
enum ProviderType {
  local,
  remote,
  federated,
}
ProviderType toProviderType(string value) {
  mixin(EnumSwitch("ProviderType", "local"));
}
ProviderType[] toProviderType(string[] values) {
  return values.map!(v => toProviderType(v));
}
string toString(ProviderType type) {
  return type.to!string;
}
string[] toString(ProviderType[] types) {
  return types.map!(t => toString(t));
}
///
unittest {
  assert(toProviderType("local") == ProviderType.local);
  assert(toProviderType("remote") == ProviderType.remote);
  assert(toProviderType("federated") == ProviderType.federated);
  assert(toProviderType("unknown") == ProviderType.local); // default to local

  assert(toString(ProviderType.local) == "local");
  assert(toString(ProviderType.remote) == "remote");
  assert(toString(ProviderType.federated) == "federated");

  assert(toProviderType(["local", "remote", "federated", "unknown"]) ==
         [ProviderType.local, ProviderType.remote, ProviderType.federated, ProviderType.local]);
  assert(toString([ProviderType.local, ProviderType.remote, ProviderType.federated]) ==
         ["local", "remote", "federated"]);
}

/// Theme mode.
enum ThemeMode {
  light,
  dark,
  highContrast,
  highContrastDark,
}
ThemeMode toThemeMode(string value) {
  mixin(EnumSwitch("ThemeMode", "light"));
}
ThemeMode[] toThemeMode(string[] values) {
  return values.map!(v => toThemeMode(v));
}
string toString(ThemeMode mode) {
  return mode.to!string;
}
string[] toString(ThemeMode[] modes) {
  return modes.map!(m => toString(m));
}
///
unittest {
  assert(toThemeMode("light") == ThemeMode.light);
  assert(toThemeMode("dark") == ThemeMode.dark);
  assert(toThemeMode("highContrast") == ThemeMode.highContrast);
  assert(toThemeMode("highContrastDark") == ThemeMode.highContrastDark);
  assert(toThemeMode("unknown") == ThemeMode.light); // default to light

  assert(toString(ThemeMode.light) == "light");
  assert(toString(ThemeMode.dark) == "dark");
  assert(toString(ThemeMode.highContrast) == "highContrast");
  assert(toString(ThemeMode.highContrastDark) == "highContrastDark");

  assert(toThemeMode(["light", "dark", "highContrast", "highContrastDark", "unknown"]) ==
         [ThemeMode.light, ThemeMode.dark, ThemeMode.highContrast, ThemeMode.highContrastDark, ThemeMode.light]);
  assert(toString([ThemeMode.light, ThemeMode.dark, ThemeMode.highContrast, ThemeMode.highContrastDark]) ==
         ["light", "dark", "highContrast", "highContrastDark"]);
}

/// Navigation target type.
enum NavigationTarget {
  inPlace,
  newWindow,
  embedded,
}
NavigationTarget toNavigationTarget(string value) {
  mixin(EnumSwitch("NavigationTarget", "inPlace"));
}
NavigationTarget[] toNavigationTarget(string[] values) {
  return values.map!(v => toNavigationTarget(v));
}
string toString(NavigationTarget target) {
  return target.to!string;
}
string[] toString(NavigationTarget[] targets) {
  return targets.map!(t => toString(t));
}
///
unittest {
  assert(toNavigationTarget("inPlace") == NavigationTarget.inPlace);
  assert(toNavigationTarget("newWindow") == NavigationTarget.newWindow);
  assert(toNavigationTarget("embedded") == NavigationTarget.embedded);
  assert(toNavigationTarget("unknown") == NavigationTarget.inPlace); // default to inPlace

  assert(toString(NavigationTarget.inPlace) == "inPlace");
  assert(toString(NavigationTarget.newWindow) == "newWindow");
  assert(toString(NavigationTarget.embedded) == "embedded");

  assert(toNavigationTarget(["inPlace", "newWindow", "embedded", "unknown"]) ==
         [NavigationTarget.inPlace, NavigationTarget.newWindow, NavigationTarget.embedded, NavigationTarget.inPlace]);
  assert(toString([NavigationTarget.inPlace, NavigationTarget.newWindow, NavigationTarget.embedded]) ==
         ["inPlace", "newWindow", "embedded"]);
}

/// Transport status.
enum TransportStatus {
  pending,
  inProgress,
  completed,
  failed,
}
TransportStatus toTransportStatus(string value) {
  mixin(EnumSwitch("TransportStatus", "pending"));
}
TransportStatus[] toTransportStatus(string[] values) {
  return values.map!(v => toTransportStatus(v));
}
string toString(TransportStatus status) {
  return status.to!string;
}
string[] toString(TransportStatus[] statuses) {
  return statuses.map!(s => toString(s));
}
///
unittest {
  assert(toTransportStatus("pending") == TransportStatus.pending);
  assert(toTransportStatus("inProgress") == TransportStatus.inProgress);
  assert(toTransportStatus("completed") == TransportStatus.completed);
  assert(toTransportStatus("failed") == TransportStatus.failed);
  assert(toTransportStatus("unknown") == TransportStatus.pending); // default to pending

  assert(toString(TransportStatus.pending) == "pending");
  assert(toString(TransportStatus.inProgress) == "inProgress");
  assert(toString(TransportStatus.completed) == "completed");
  assert(toString(TransportStatus.failed) == "failed");

  assert(toTransportStatus(["pending", "inProgress", "completed", "failed", "unknown"]) ==
         [TransportStatus.pending, TransportStatus.inProgress, TransportStatus.completed, TransportStatus.failed, TransportStatus.pending]);
  assert(toString([TransportStatus.pending, TransportStatus.inProgress, TransportStatus.completed, TransportStatus.failed]) ==
         ["pending", "inProgress", "completed", "failed"]);
}

/// Role assignment scope.
enum RoleScope {
  site,
  catalog,
  group,
  page,
}
RoleScope toRoleScope(string value) {
  mixin(EnumSwitch("RoleScope", "site"));
}
RoleScope[] toRoleScope(string[] values) {
  return values.map!(v => toRoleScope(v));
}
string toString(RoleScope value) {
  return value.to!string;
}
string[] toString(RoleScope[] values) {
  return values.map!(v => toString(v));
}
///
unittest {
  assert(toRoleScope("site") == RoleScope.site);
  assert(toRoleScope("catalog") == RoleScope.catalog);
  assert(toRoleScope("group") == RoleScope.group);
  assert(toRoleScope("page") == RoleScope.page);
  assert(toRoleScope("unknown") == RoleScope.site); // default to site

  assert(toString(RoleScope.site) == "site");
  assert(toString(RoleScope.catalog) == "catalog");
  assert(toString(RoleScope.group) == "group");
  assert(toString(RoleScope.page) == "page");

  assert(toRoleScope(["site", "catalog", "group", "page", "unknown"]) ==
         [RoleScope.site, RoleScope.catalog, RoleScope.group, RoleScope.page, RoleScope.site]);
  assert(toString([RoleScope.site, RoleScope.catalog, RoleScope.group, RoleScope.page]) ==
         ["site", "catalog", "group", "page"]);
}