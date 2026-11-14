/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Resolves the content tree of a site: Site → Pages → Sections → Tiles, plus the
/// hierarchical menu. At runtime only visible content the user's roles allow is kept.
module uim.platform.portal.domain.services.content_resolver;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// All content a site can reference (input of the resolver).
struct PortalContent {
  PortalSite site;
  PortalPage[] pages;
  PortalSection[] sections;
  PortalTile[] tiles;
  PortalCatalog[] catalogs;
  PortalMenuItem[] menuItems;
  /// isNull = SAP base theme only.
  PortalTheme theme;
}

struct ResolvedSection {
  PortalSection section;
  PortalTile[] tiles;
}

struct ResolvedPage {
  PortalPage page;
  ResolvedSection[] sections;
}

struct ResolvedMenuItem {
  PortalMenuItem item;
  /// Alias of the target page ("" for URL targets and folders).
  string targetPageAlias;
  ResolvedMenuItem[] children;
}

struct ResolvedSite {
  PortalSite site;
  PortalTheme theme;
  ResolvedPage[] pages;
  ResolvedMenuItem[] menu;

  /// Number of tile placements on all pages.
  size_t tileCount() const {
    size_t n;
    foreach (p; pages)
      foreach (s; p.sections)
        n += s.tiles.length;
    return n;
  }
}

/// Maximum depth of the navigation menu (protects against parent cycles).
enum maxMenuDepth = 8;

private bool bySortOrder(T)(const ref T a, const ref T b) {
  return a.sortOrder != b.sortOrder ? a.sortOrder < b.sortOrder : a.name < b.name;
}

/// Resolve the content of `content.site` for `access`.
ResolvedSite resolveSite(PortalContent content, AccessScope access) {
  ResolvedSite result;
  result.site = content.site;
  result.theme = content.theme;
  auto siteId = content.site.id;

  PortalCatalog[CatalogId] catalogs;
  foreach (c; content.catalogs)
    catalogs[c.id] = c;
  PortalTile[TileId] tiles;
  foreach (t; content.tiles)
    tiles[t.id] = t;

  bool tileAllowed(PortalTile t) {
    if (!access.restricted)
      return true;
    if (!t.visible || !access.allows(t.allowedRoleIds))
      return false;
    auto c = t.catalogId in catalogs;
    return c !is null && c.active && access.allows(c.allowedRoleIds);
  }

  auto pages = content.pages.filter!(p => p.siteId == siteId).array;
  pages.sort!((a, b) => bySortOrder(a, b));
  string[PageId] aliases;
  foreach (page; pages) {
    if (access.restricted && (!page.visible || !access.allows(page.allowedRoleIds)))
      continue;
    aliases[page.id] = page.alias_;
    ResolvedPage rp;
    rp.page = page;
    auto sections = content.sections.filter!(s => s.pageId == page.id).array;
    sections.sort!((a, b) => bySortOrder(a, b));
    foreach (section; sections) {
      if (access.restricted && !section.visible)
        continue;
      ResolvedSection rs;
      rs.section = section;
      foreach (tid; section.tileIds)
        if (auto t = tid in tiles)
          if (tileAllowed(*t))
            rs.tiles ~= *t;
      rp.sections ~= rs;
    }
    result.pages ~= rp;
  }

  auto items = content.menuItems.filter!(m => m.siteId == siteId).array;
  items.sort!((a, b) => bySortOrder(a, b));

  ResolvedMenuItem[] children(MenuItemId parent, int depth) {
    ResolvedMenuItem[] level;
    if (depth >= maxMenuDepth)
      return level;
    foreach (item; items) {
      if (item.parentItemId != parent)
        continue;
      // top level: items whose parent does not exist count as top level
      if (access.restricted && (!item.visible || !access.allows(item.allowedRoleIds)))
        continue;
      ResolvedMenuItem r;
      r.item = item;
      if (!item.targetPageId.isEmpty) {
        auto a = item.targetPageId in aliases;
        if (a is null && access.restricted)
          continue; // page not visible for this user
        r.targetPageAlias = a is null ? "" : *a;
      }
      r.children = children(item.id, depth + 1);
      if (access.restricted && item.targetPageId.isEmpty && item.targetUrl.length == 0 && r.children.length == 0)
        continue; // empty folder
      level ~= r;
    }
    return level;
  }

  // orphans (parent deleted) are shown at the top level
  bool[MenuItemId] known;
  foreach (item; items)
    known[item.id] = true;
  foreach (ref item; items)
    if (!item.parentItemId.isEmpty && item.parentItemId !in known)
      item.parentItemId = MenuItemId.init;
  result.menu = children(MenuItemId.init, 0);
  return result;
}

///
unittest {
  auto t = TenantId("t");
  auto sales = PortalRoleId("sales");

  PortalContent c;
  c.site = PortalSite(t, SiteId("s"));
  c.site.alias_ = "home";

  auto catalog = PortalCatalog(t, CatalogId("c"));
  catalog.name = "Apps";
  auto open = PortalTile(t, TileId("open"));
  open.catalogId = catalog.id;
  open.name = "Open";
  auto secret = PortalTile(t, TileId("secret"));
  secret.catalogId = catalog.id;
  secret.name = "Secret";
  secret.allowedRoleIds = [sales];
  auto hidden = PortalTile(t, TileId("hidden"));
  hidden.catalogId = catalog.id;
  hidden.visible = false;

  auto p2 = PortalPage(t, PageId("p2"));
  p2.siteId = c.site.id;
  p2.name = "B";
  p2.alias_ = "b";
  p2.sortOrder = 2;
  auto p1 = PortalPage(t, PageId("p1"));
  p1.siteId = c.site.id;
  p1.name = "A";
  p1.alias_ = "a";
  p1.sortOrder = 1;
  p1.allowedRoleIds = [sales];

  auto sec = PortalSection(t, SectionId("x"));
  sec.pageId = p2.id;
  sec.tileIds = [secret.id, open.id, hidden.id, TileId("gone")];

  auto menu = PortalMenuItem(t, MenuItemId("m1"));
  menu.siteId = c.site.id;
  menu.name = "A";
  menu.targetPageId = p1.id;

  c.pages = [p2, p1];
  c.sections = [sec];
  c.tiles = [open, secret, hidden];
  c.catalogs = [catalog];
  c.menuItems = [menu];

  auto design = resolveSite(c, AccessScope.designTime);
  assert(design.pages.length == 2 && design.pages[0].page.name == "A"); // sorted
  assert(design.tileCount == 3); // unknown tile id skipped
  assert(design.menu.length == 1 && design.menu[0].targetPageAlias == "a");

  auto anonymous = resolveSite(c, AccessScope.forRoles(null));
  assert(anonymous.pages.length == 1 && anonymous.pages[0].page.name == "B");
  assert(anonymous.tileCount == 1 && anonymous.pages[0].sections[0].tiles[0].name == "Open");
  assert(anonymous.menu.length == 0); // target page not visible

  auto seller = resolveSite(c, AccessScope.forRoles([sales]));
  assert(seller.pages.length == 2 && seller.tileCount == 2 && seller.menu.length == 1);

  c.catalogs[0].active = false;
  assert(resolveSite(c, AccessScope.forRoles([sales])).tileCount == 0);
}
