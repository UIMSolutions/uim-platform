/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Renders content as Common Data Model (CDM 3.1) documents — the JSON format
/// SAP Build Work Zone uses to exchange sites, pages, catalogs and apps.
module uim.platform.portal.domain.services.cdm;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

enum cdmVersion = "3.1.0";

private Json strings(const string[] values) {
  auto arr = Json.emptyArray;
  foreach (v; values)
    arr ~= Json(v);
  return arr;
}

private Json ids(T)(const T[] values) {
  auto arr = Json.emptyArray;
  foreach (v; values)
    arr ~= Json(v.value);
  return arr;
}

/// { "_version", "identification": {...}, "payload": payload }
Json cdmDocument(string entityType, string id, string title, string description, Json payload) {
  auto ident = Json.emptyObject;
  ident["id"] = id;
  ident["entityType"] = entityType;
  ident["title"] = title;
  if (description.length > 0)
    ident["description"] = description;
  auto doc = Json.emptyObject;
  doc["_version"] = cdmVersion;
  doc["identification"] = ident;
  doc["payload"] = payload;
  return doc;
}

/// The launch target of a tile.
Json tileTarget(const ref PortalTile tile) {
  auto target = Json.emptyObject;
  target["appType"] = enumText(tile.appType);
  target["navigationMode"] = enumText(tile.navigationTarget);
  if (tile.intent.length > 0) {
    target["semanticObject"] = tile.semanticObject;
    target["action"] = tile.action;
    target["intent"] = tile.intent;
  }
  if (tile.url.length > 0)
    target["url"] = tile.url;
  if (tile.appId.length > 0)
    target["appId"] = tile.appId;
  return target;
}

/// A tile as CDM visualization.
Json cdmVisualization(const ref PortalTile tile) {
  auto p = Json.emptyObject;
  p["vizType"] = enumText(tile.tileType);
  p["title"] = tile.name;
  p["subtitle"] = tile.subtitle;
  p["icon"] = tile.icon;
  p["info"] = tile.info;
  p["size"] = enumText(tile.size);
  p["keywords"] = strings(tile.keywords);
  p["target"] = tileTarget(tile);
  if (tile.tileType == TileType.dynamic || tile.tileType == TileType.kpi) {
    auto data = Json.emptyObject;
    data["serviceUrl"] = tile.serviceUrl;
    data["refreshIntervalSeconds"] = tile.refreshIntervalSeconds;
    data["numberUnit"] = tile.numberUnit;
    data["targetNumber"] = tile.targetNumber;
    data["indicatorColor"] = enumText(tile.indicatorColor);
    p["indicatorDataSource"] = data;
  }
  return cdmDocument("visualization", tile.id.value, tile.name, tile.description, p);
}

Json cdmSection(const ref ResolvedSection s) {
  auto viz = Json.emptyArray;
  foreach (t; s.tiles)
    viz ~= cdmVisualization(t);
  auto p = Json.emptyObject;
  p["columns"] = s.section.columns;
  p["viz"] = viz;
  return cdmDocument("section", s.section.id.value, s.section.name, s.section.description, p);
}

Json cdmPage(const ref ResolvedPage page) {
  auto sections = Json.emptyArray;
  foreach (s; page.sections)
    sections ~= cdmSection(s);
  auto p = Json.emptyObject;
  p["alias"] = page.page.alias_;
  p["layout"] = enumText(page.page.layout);
  p["sections"] = sections;
  return cdmDocument("page", page.page.id.value, page.page.name, page.page.description, p);
}

Json cdmMenu(const ResolvedMenuItem[] items) {
  auto arr = Json.emptyArray;
  foreach (m; items) {
    auto j = Json.emptyObject;
    j["id"] = m.item.id.value;
    j["title"] = m.item.name;
    j["icon"] = m.item.icon;
    auto target = Json.emptyObject;
    if (!m.item.targetPageId.isEmpty) {
      target["type"] = "page";
      target["pageId"] = m.item.targetPageId.value;
      target["pageAlias"] = m.targetPageAlias;
    } else if (m.item.targetUrl.length > 0) {
      target["type"] = "url";
      target["url"] = m.item.targetUrl;
    } else
      target["type"] = "folder";
    target["navigationMode"] = enumText(m.item.navigationTarget);
    j["target"] = target;
    j["children"] = cdmMenu(m.children);
    arr ~= j;
  }
  return arr;
}

/// Theming parameters (SAP theme designer names) of a theme.
Json themeParameters(const ref PortalTheme theme) {
  auto p = Json.emptyObject;
  void put(string parameter, string value) {
    if (value.length > 0)
      p[parameter] = value;
  }

  put("sapBrandColor", theme.primaryColor);
  put("sapHighlightColor", theme.secondaryColor);
  put("sapAccentColor1", theme.accentColor);
  put("sapBackgroundColor", theme.backgroundColor);
  put("sapShellColor", theme.shellColor);
  put("sapTextColor", theme.textColor);
  put("sapLinkColor", theme.linkColor);
  put("sapPageHeader_Background", theme.headerColor);
  put("sapPageFooter_Background", theme.footerColor);
  put("sapTile_Background", theme.tileBackgroundColor);
  put("sapFontFamily", theme.fontFamily);
  put("sapFontHeaderFamily", theme.headerFontFamily);
  put("sapFontSize", theme.fontSize);
  put("sapFontHeader2Size", theme.headerFontSize);
  return p;
}

Json cdmTheme(const ref PortalTheme theme) {
  auto p = Json.emptyObject;
  p["baseTheme"] = enumText(theme.baseTheme);
  p["mode"] = enumText(theme.mode);
  p["isDefault"] = theme.isDefault;
  p["parameters"] = themeParameters(theme);
  p["customCss"] = theme.customCss;
  return cdmDocument("theme", theme.id.value, theme.name, theme.description, p);
}

/// The complete site document (pages, sections, visualizations, menu, theme).
Json cdmSite(const ref ResolvedSite r) {
  auto s = r.site;
  auto settings = Json.emptyObject;
  settings["logoUrl"] = s.logoUrl;
  settings["faviconUrl"] = s.faviconUrl;
  settings["footerText"] = s.footerText;
  settings["copyrightText"] = s.copyrightText;
  settings["defaultLanguage"] = s.defaultLanguage;
  settings["supportedLanguages"] = strings(s.supportedLanguages);
  auto shell = Json.emptyObject;
  shell["personalization"] = s.showPersonalization;
  shell["notifications"] = s.showNotifications;
  shell["search"] = s.showSearch;
  shell["userActions"] = s.showUserActions;
  settings["shell"] = shell;

  auto pages = Json.emptyArray;
  foreach (p; r.pages)
    pages ~= cdmPage(p);

  auto p = Json.emptyObject;
  p["alias"] = s.alias_;
  p["url"] = s.runtimeUrl;
  p["status"] = enumText(s.status);
  p["publishedVersion"] = s.publishedVersion;
  p["publishedAt"] = isoTime(s.publishedAt);
  p["config"] = settings;
  p["theme"] = r.theme.isNull ? Json(null) : cdmTheme(r.theme)["payload"];
  p["pages"] = pages;
  p["menu"] = cdmMenu(r.menu);
  p["allowedRoles"] = ids(s.allowedRoleIds);
  return cdmDocument("site", s.id.value, s.name, s.description, p);
}

Json cdmCatalog(const ref PortalCatalog catalog, const PortalTile[] tiles) {
  auto viz = Json.emptyArray;
  foreach (t; tiles)
    if (t.catalogId == catalog.id)
      viz ~= cdmVisualization(t);
  auto p = Json.emptyObject;
  p["providerId"] = catalog.providerId.value;
  p["active"] = catalog.active;
  p["allowedRoles"] = ids(catalog.allowedRoleIds);
  p["viz"] = viz;
  return cdmDocument("catalog", catalog.id.value, catalog.name, catalog.description, p);
}

Json cdmProvider(const ref ContentProvider provider, const PortalCatalog[] catalogs) {
  auto list = Json.emptyArray;
  foreach (c; catalogs)
    if (c.providerId == provider.id)
      list ~= Json(c.id.value);
  auto p = Json.emptyObject;
  p["providerType"] = enumText(provider.providerType);
  p["contentEndpointUrl"] = provider.contentEndpointUrl;
  p["destinationName"] = provider.destinationName;
  p["status"] = enumText(provider.status);
  p["lastSyncedAt"] = isoTime(provider.lastSyncedAt);
  p["catalogs"] = list;
  return cdmDocument("contentProvider", provider.id.value, provider.name, provider.description, p);
}

/// A role with the content it grants (ids of sites, catalogs, pages, tiles).
Json cdmRole(const ref PortalRole role, string[] siteIds, string[] catalogIds, string[] pageIds, string[] tileIds) {
  auto p = Json.emptyObject;
  p["scope"] = enumText(role.scope_);
  p["users"] = strings(role.userIds);
  p["groups"] = strings(role.groupIds);
  p["sites"] = strings(siteIds);
  p["catalogs"] = strings(catalogIds);
  p["pages"] = strings(pageIds);
  p["apps"] = strings(tileIds);
  return cdmDocument("role", role.id.value, role.name, role.description, p);
}

///
unittest {
  auto tile = PortalTile(TenantId("t"), TileId("x"));
  tile.name = "Orders";
  tile.tileType = TileType.kpi;
  tile.appType = AppType.sapui5;
  tile.semanticObject = "SalesOrder";
  tile.action = "display";
  tile.serviceUrl = "/odata/kpi";
  auto viz = cdmVisualization(tile);
  assert(viz["_version"].get!string == cdmVersion);
  assert(viz["identification"]["entityType"].get!string == "visualization");
  assert(viz["payload"]["target"]["intent"].get!string == "#SalesOrder-display");
  assert(viz["payload"]["indicatorDataSource"]["serviceUrl"].get!string == "/odata/kpi");

  auto theme = PortalTheme(TenantId("t"));
  theme.primaryColor = "#0a6ed1";
  assert(themeParameters(theme)["sapBrandColor"].get!string == "#0a6ed1");
  assert("sapShellColor" !in themeParameters(theme));
}
