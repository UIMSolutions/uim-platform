/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.sites;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: sites. Names and aliases are unique; publishing needs a visible
/// navigation entry; published sites must be unpublished before deletion.
class ManageSitesUseCase : ResourceUseCase!(Site, SiteId, CreateSiteRequest, UpdateSiteRequest), IManageSitesUseCase {
  protected CascadeDeleter cascade;

  this(WorkzoneRepositories repos, CascadeDeleter cascade, IWorkzoneEventPublisher publisher) {
    super(repos, repos.sites, publisher, "Site", "workzone.site");
    this.cascade = cascade;
  }

  override protected Site build(CreateSiteRequest r) {
    auto s = Site(r.tenantId);
    assignMatching(s, r.spec);
    if (s.themeId.isEmpty) {
      auto defaults = repos.themes.findMatching(r.tenantId, (const Theme t) => t.isDefault);
      if (defaults.length > 0)
        s.themeId = defaults[0].id;
    }
    check(s);
    return s;
  }

  override protected void apply(ref Site s, SiteSpec spec) {
    ensureState(s.status != SiteStatus.archived, "Site '" ~ s.name ~ "' is archived");
    auto previous = s.name;
    assignMatching(s, spec);
    check(s);
    if (previous != s.name) // keep shell plugin assignments
      foreach (p; repos.shellPlugins.findMatching(s.tenantId, (const ShellPlugin p) => p.assignedSites.canFind(previous))) {
        p.assignedSites = p.assignedSites.map!(n => n == previous ? s.name : n).array;
        repos.shellPlugins.update(p);
      }
  }

  protected void check(ref Site s) {
    s.name = s.name.strip;
    validateDisplayName("Site name", s.name, 80);
    ensureUnique(repos.sites.findByName(s.tenantId, s.name), s);
    s.alias_ = s.alias_.strip.length ? s.alias_.strip : toSlug(s.name);
    validateSlug("Site alias", s.alias_);
    auto alias_ = s.alias_;
    auto id = s.id;
    ensureState(repos.sites.findMatching(s.tenantId, (const Site o) => o.id != id && o.alias_ == alias_).length == 0,
      "Site alias '" ~ s.alias_ ~ "' is already used");
    s.themeName = "";
    if (!s.themeId.isEmpty) {
      auto t = repos.themes.findById(s.tenantId, s.themeId);
      ensureFound(!t.isNull, "Theme '" ~ s.themeId.value ~ "' not found");
      s.themeName = t.name;
    }
    validate(s.logoUrl.length == 0 || isLaunchTarget(s.logoUrl), "Logo '" ~ s.logoUrl ~ "' is not a valid URL");
    validate(s.faviconUrl.length == 0 || isLaunchTarget(s.faviconUrl), "Favicon '" ~ s.faviconUrl ~ "' is not a valid URL");
    s.allowedRoles = requireRoles(s.tenantId, s.allowedRoles);
  }

  override protected void beforeRemove(Site s) {
    ensureState(s.status != SiteStatus.published, "Site '" ~ s.name ~ "' is published — unpublish or archive it first");
  }

  override protected void afterRemove(Site s) {
    cascade.clearSite(s.tenantId, s);
  }

  UsecaseResult publish(TenantId tenantId, SiteId id, UserId actor) {
    return transition(tenantId, id, actor, "published", (ref Site s) {
      ensureState(s.status == SiteStatus.draft || s.status == SiteStatus.maintenance, "Site '" ~ s.name ~ "' is "
          ~ enumText(s.status));
      auto siteId = s.id;
      auto entries = repos.navigationItems.findMatching(tenantId, (const NavigationItem n) => n.siteId == siteId && n.visible);
      ensureState(entries.length > 0, "Site '" ~ s.name ~ "' needs at least one visible navigation item before publishing");
      s.status = SiteStatus.published;
      s.publishedAt = nowStdTime();
    });
  }

  UsecaseResult unpublish(TenantId tenantId, SiteId id, UserId actor) {
    return transition(tenantId, id, actor, "unpublished", (ref Site s) {
      ensureState(s.status == SiteStatus.published || s.status == SiteStatus.maintenance, "Site '" ~ s.name ~ "' is not published");
      s.status = SiteStatus.draft;
    });
  }

  UsecaseResult startMaintenance(TenantId tenantId, SiteId id, UserId actor) {
    return transition(tenantId, id, actor, "in maintenance", (ref Site s) {
      ensureState(s.status == SiteStatus.published, "Only published sites can go into maintenance");
      s.status = SiteStatus.maintenance;
    });
  }

  UsecaseResult archive(TenantId tenantId, SiteId id, UserId actor) {
    return transition(tenantId, id, actor, "archived", (ref Site s) {
      ensureState(s.status != SiteStatus.archived, "Site '" ~ s.name ~ "' is already archived");
      s.status = SiteStatus.archived;
    });
  }
}

/// Interactor: navigation entries. Parents must be group entries of the same
/// site (no cycles); app / workpage targets must exist.
class ManageNavigationItemsUseCase
  : ResourceUseCase!(NavigationItem, NavigationItemId, CreateNavigationItemRequest, UpdateNavigationItemRequest),
  IManageNavigationItemsUseCase {

  this(WorkzoneRepositories repos, IWorkzoneEventPublisher publisher) {
    super(repos, repos.navigationItems, publisher, "Navigation item", "workzone.navigation-item");
  }

  override protected NavigationItem build(CreateNavigationItemRequest r) {
    validate(!r.parentId.isEmpty, "siteId is required");
    auto s = repos.sites.findById(r.tenantId, r.parentId);
    ensureFound(!s.isNull, "Site '" ~ r.parentId.value ~ "' not found");
    ensureState(s.status != SiteStatus.archived, "Site '" ~ s.name ~ "' is archived");
    auto n = NavigationItem(r.tenantId);
    n.siteId = s.id;
    n.siteName = s.name;
    assignMatching(n, r.spec);
    check(n);
    return n;
  }

  override protected void apply(ref NavigationItem n, NavigationItemSpec spec) {
    assignMatching(n, spec);
    check(n);
  }

  protected void check(ref NavigationItem n) {
    n.title = n.title.strip;
    if (n.itemType != NavigationItemType.separator)
      validateDisplayName("Navigation title", n.title, 80);
    validateNavigationTarget(n);
    n.targetAppName = "";
    if (n.itemType == NavigationItemType.app) {
      auto a = repos.apps.findById(n.tenantId, n.targetAppId);
      ensureFound(!a.isNull, "App '" ~ n.targetAppId.value ~ "' not found");
      ensureState(a.status != AppStatus.deprecated_, "App '" ~ a.name ~ "' is deprecated");
      n.targetAppName = a.name;
    }
    if (n.itemType == NavigationItemType.workpage)
      ensureFound(!repos.workpages.findById(n.tenantId, n.targetWorkpageId).isNull,
        "Workpage '" ~ n.targetWorkpageId.value ~ "' not found");
    if (!n.parentId.isEmpty) {
      auto parent = repos.navigationItems.findById(n.tenantId, n.parentId);
      ensureFound(!parent.isNull, "Parent navigation item '" ~ n.parentId.value ~ "' not found");
      validate(parent.siteId == n.siteId, "The parent entry belongs to another site");
      validate(parent.itemType == NavigationItemType.group, "Only group entries can have children");
      auto siteId = n.siteId;
      validate(!createsCycle(repos.navigationItems.findMatching(n.tenantId, (const NavigationItem x) => x.siteId == siteId),
          n.id, n.parentId), "The parent entry would create a cycle");
    }
    n.allowedRoles = requireRoles(n.tenantId, n.allowedRoles);
  }

  override protected void beforeRemove(NavigationItem n) {
    auto id = n.id;
    auto children = repos.navigationItems.findMatching(n.tenantId, (const NavigationItem x) => x.parentId == id);
    ensureState(children.length == 0, "Navigation group '" ~ n.title ~ "' still has " ~ children.length.to!string ~ " entr(ies)");
    auto s = repos.sites.findById(n.tenantId, n.siteId);
    if (!s.isNull && s.status == SiteStatus.published) {
      auto siteId = n.siteId;
      auto visible = repos.navigationItems.findMatching(n.tenantId,
        (const NavigationItem x) => x.siteId == siteId && x.visible && x.id != id);
      ensureState(visible.length > 0, "The last visible entry of published site '" ~ s.name ~ "' cannot be deleted");
    }
  }
}
