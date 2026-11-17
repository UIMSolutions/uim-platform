/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.services.cascade;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Removes what lives in a workspace, workpage or site when it is deleted.
class CascadeDeleter {
  protected WorkzoneRepositories repos;

  this(WorkzoneRepositories repos) {
    this.repos = repos;
  }

  /// Delete everything inside a workspace. Returns the number of removed aggregates.
  size_t clearWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    size_t removed;
    void clear(R)(R repo) {
      auto items = repo.findByWorkspace(tenantId, workspaceId);
      removed += items.length;
      if (items.length > 0)
        repo.remove(items);
    }

    clear(repos.widgets);
    clear(repos.workpages);
    clear(repos.channels);
    clear(repos.content);
    clear(repos.feedEntries);
    clear(repos.events);
    clear(repos.surveys);
    clear(repos.forumTopics);
    clear(repos.knowledgeBase);
    return removed;
  }

  /// Delete the widgets of a workpage.
  size_t clearWorkpage(TenantId tenantId, WorkpageId workpageId) {
    auto items = repos.widgets.findMatching(tenantId, (const PageWidget w) => w.workpageId == workpageId);
    if (items.length > 0)
      repos.widgets.remove(items);
    return items.length;
  }

  /// Delete the navigation of a site and unassign it from shell plugins.
  size_t clearSite(TenantId tenantId, const Site site) {
    auto items = repos.navigationItems.findMatching(tenantId, (const NavigationItem n) => n.siteId == site.id);
    if (items.length > 0)
      repos.navigationItems.remove(items);
    foreach (p; repos.shellPlugins.findMatching(tenantId, (const ShellPlugin p) => p.assignedSites.canFind(site.name))) {
      p.assignedSites = p.assignedSites.filter!(s => s != site.name).array;
      repos.shellPlugins.update(p);
    }
    return items.length;
  }
}
