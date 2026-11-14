/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business rules of the content aggregates.
module uim.platform.portal.domain.services.validators;

import std.ascii : isAlpha, isAlphaNum, isDigit, isHexDigit;
import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// "#0a6ed1", "#fff" or "#0a6ed1cc".
bool isHexColor(string s) pure nothrow {
  if (s.length != 4 && s.length != 7 && s.length != 9)
    return false;
  if (s[0] != '#')
    return false;
  foreach (c; s[1 .. $])
    if (!isHexDigit(c))
      return false;
  return true;
}

/// "14px", "0.875rem", "1em", "100%", "12pt".
bool isCssSize(string s) pure {
  import std.string : endsWith;

  foreach (unit; ["rem", "px", "em", "pt", "%"])
    if (s.endsWith(unit)) {
      auto n = s[0 .. $ - unit.length];
      if (n.length == 0)
        return false;
      bool dot;
      foreach (c; n) {
        if (c == '.' && !dot)
          dot = true;
        else if (!isDigit(c))
          return false;
      }
      return true;
    }
  return false;
}

/// A launchpad semantic object or action name ("SalesOrder", "display").
bool isIntentPart(string s) pure nothrow {
  if (s.length == 0 || s.length > 60 || !isAlpha(s[0]))
    return false;
  foreach (c; s)
    if (!isAlphaNum(c) && c != '_')
      return false;
  return true;
}

void validateName(string kind, string name, size_t maxLength = 120) {
  import std.string : strip;

  validate(name.strip.length > 0, kind ~ " name is required");
  validate(name.length <= maxLength, kind ~ " name must not exceed " ~ maxLength.to!string ~ " characters");
}

void validateSite(const ref PortalSite site) {
  validateName("Site", site.name);
  validateAlias("Site", site.alias_);
  validateLanguage("Default language", site.defaultLanguage);
  foreach (lang; site.supportedLanguages)
    validateLanguage("Supported language", lang);
  validate(site.logoUrl.length == 0 || isNavigableUrl(site.logoUrl), "logoUrl must be an http(s) URL or a path");
  validate(site.faviconUrl.length == 0 || isNavigableUrl(site.faviconUrl), "faviconUrl must be an http(s) URL or a path");
}

void validatePage(const ref PortalPage page) {
  validateName("Page", page.name);
  validateAlias("Page", page.alias_);
  validate(page.sortOrder >= 0, "sortOrder must not be negative");
}

void validateSection(const ref PortalSection section) {
  validateName("Section", section.name);
  validate(section.columns >= 1 && section.columns <= 12, "columns must be between 1 and 12");
  validate(section.sortOrder >= 0, "sortOrder must not be negative");
}

/// Tiles need a launch target matching their app type; dynamic and KPI tiles need a data service.
void validateTile(const ref PortalTile tile) {
  validateName("Tile", tile.name);
  validate(isIconRef(tile.icon), "icon must be 'sap-icon://<name>' or an image URL");
  validate((tile.semanticObject.length == 0) == (tile.action.length == 0),
    "semanticObject and action must be set together");
  if (tile.semanticObject.length > 0)
    validate(isIntentPart(tile.semanticObject) && isIntentPart(tile.action),
      "semanticObject and action must start with a letter and contain only letters, digits and '_'");
  validate(tile.url.length == 0 || isNavigableUrl(tile.url), "url '" ~ tile.url ~ "' is not an http(s) URL, path or intent");

  final switch (tile.appType) {
  case AppType.url:
    validate(tile.url.length > 0, "A URL tile needs a url");
    break;
  case AppType.sapui5:
    validate(tile.appId.length > 0 || tile.intent.length > 0,
      "An SAPUI5 tile needs an appId (component id) or semanticObject + action");
    break;
  case AppType.webDynpro, AppType.sapGuiHtml, AppType.webComponent, AppType.native:
    validate(tile.url.length > 0 || tile.intent.length > 0, "This tile needs a url or semanticObject + action");
    break;
  }

  if (tile.tileType == TileType.dynamic || tile.tileType == TileType.kpi)
    validate(tile.serviceUrl.length > 0 && isNavigableUrl(tile.serviceUrl),
      "Dynamic and KPI tiles need a serviceUrl delivering the number");
  validate(tile.refreshIntervalSeconds == 0 || (tile.refreshIntervalSeconds >= 10 && tile.refreshIntervalSeconds <= 86_400),
    "refreshIntervalSeconds must be 0 (off) or between 10 and 86400");
  if (tile.targetNumber.length > 0) {
    bool numeric = true;
    try
      tile.targetNumber.to!double;
    catch (Exception)
      numeric = false;
    validate(numeric, "targetNumber must be a number");
  }
}

void validateCatalog(const ref PortalCatalog catalog) {
  validateName("Catalog", catalog.name);
}

/// Remote and federated providers need an https endpoint; local providers have none.
void validateProvider(const ref ContentProvider provider) {
  validateName("Content provider", provider.name);
  if (provider.providerType == ProviderType.local)
    validate(provider.contentEndpointUrl.length == 0, "A local provider has no contentEndpointUrl");
  else
    validate(isHttpsUrl(provider.contentEndpointUrl),
      "A " ~ enumText(provider.providerType) ~ " provider needs an https contentEndpointUrl");
}

void validateRole(const ref PortalRole role) {
  validateName("Role", role.name, 80);
  foreach (u; role.userIds)
    validate(u.length > 0 && u.length <= 256, "user ids must not be empty");
  foreach (g; role.groupIds)
    validate(g.length > 0 && g.length <= 256, "group ids must not be empty");
}

/// Colours must be CSS hex values, fonts CSS sizes; custom CSS must not break out of the style element.
void validateTheme(const ref PortalTheme theme) {
  import std.string : toLower;

  validateName("Theme", theme.name);
  static foreach (field; ["primaryColor", "secondaryColor", "accentColor", "backgroundColor", "shellColor",
      "textColor", "linkColor", "headerColor", "footerColor", "tileBackgroundColor"]) {
    validate(__traits(getMember, theme, field).length == 0 || isHexColor(__traits(getMember, theme, field)),
      field ~ " '" ~ __traits(getMember, theme, field) ~ "' must be a hex colour such as #0a6ed1");
  }
  validate(theme.fontSize.length == 0 || isCssSize(theme.fontSize), "fontSize must be a CSS size (e.g. 0.875rem)");
  validate(theme.headerFontSize.length == 0 || isCssSize(theme.headerFontSize),
    "headerFontSize must be a CSS size (e.g. 1.25rem)");
  validate(theme.customCss.length <= 65_536, "customCss must not exceed 64 KiB");
  auto css = theme.customCss.toLower;
  validate(!css.canFind("</style") && !css.canFind("<script") && !css.canFind("javascript:")
      && !css.canFind("expression("), "customCss must not contain markup or script");
}

/// A menu item targets a page OR a URL (or nothing, then it is a folder).
void validateMenuItem(const ref PortalMenuItem item) {
  validateName("Menu item", item.name);
  validate(item.targetPageId.isEmpty || item.targetUrl.length == 0, "A menu item targets either a page or a URL, not both");
  validate(item.targetUrl.length == 0 || isNavigableUrl(item.targetUrl), "targetUrl must be an http(s) URL, path or intent");
  validate(isIconRef(item.icon), "icon must be 'sap-icon://<name>' or an image URL");
  validate(item.parentItemId != item.id, "A menu item cannot be its own parent");
}

/// Fields that can be translated per resource type.
string[] translatableFields(TranslatableType type) pure {
  final switch (type) {
  case TranslatableType.site:
    return ["name", "description", "footerText", "copyrightText"];
  case TranslatableType.page, TranslatableType.section, TranslatableType.catalog:
    return ["name", "description"];
  case TranslatableType.tile:
    return ["name", "subtitle", "description", "info"];
  case TranslatableType.menuItem:
    return ["name"];
  }
}

void validateTranslation(const ref PortalTranslation t) {
  validate(t.resourceId.length > 0, "resourceId is required");
  validateLanguage("language", t.language);
  validate(translatableFields(t.resourceType).canFind(t.fieldName), "fieldName of a " ~ enumText(t.resourceType)
      ~ " must be one of " ~ translatableFields(t.resourceType).join(", "));
  validate(t.value.length > 0, "value is required");
  validate(t.value.length <= 4096, "value must not exceed 4096 characters");
}

///
unittest {
  assert(isHexColor("#0a6ed1") && isHexColor("#fff") && !isHexColor("0a6ed1") && !isHexColor("#zzz"));
  assert(isCssSize("0.875rem") && isCssSize("14px") && !isCssSize("big") && !isCssSize("px"));

  auto tile = PortalTile(TenantId("t"));
  tile.name = "Orders";
  tile.appType = AppType.url;
  bool failed;
  try validateTile(tile);
  catch (PortalValidationException) failed = true;
  assert(failed, "URL tile without url");

  tile.url = "https://orders.example.com";
  validateTile(tile);
  tile.tileType = TileType.kpi;
  failed = false;
  try validateTile(tile);
  catch (PortalValidationException) failed = true;
  assert(failed, "KPI tile without service");

  auto theme = PortalTheme(TenantId("t"));
  theme.name = "Corporate";
  theme.primaryColor = "#0a6ed1";
  validateTheme(theme);
  theme.customCss = "body{}</style><script>alert(1)</script>";
  failed = false;
  try validateTheme(theme);
  catch (PortalValidationException) failed = true;
  assert(failed, "css injection");

  auto item = PortalMenuItem(TenantId("t"));
  item.name = "Home";
  item.targetPageId = PageId("p");
  item.targetUrl = "https://x.example.com";
  failed = false;
  try validateMenuItem(item);
  catch (PortalValidationException) failed = true;
  assert(failed, "two targets");
}
