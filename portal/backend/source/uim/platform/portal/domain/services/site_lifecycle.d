/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Publishing lifecycle of sites.
module uim.platform.portal.domain.services.site_lifecycle;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Allowed status changes:
///   draft → published · published → unpublished · unpublished → published
///   draft | published | unpublished → archived · archived → draft (restore)
bool canTransition(SiteStatus from, SiteStatus to) pure nothrow {
  final switch (to) {
  case SiteStatus.published:
    return from == SiteStatus.draft || from == SiteStatus.unpublished || from == SiteStatus.published;
  case SiteStatus.unpublished:
    return from == SiteStatus.published;
  case SiteStatus.archived:
    return from != SiteStatus.archived;
  case SiteStatus.draft:
    return from == SiteStatus.archived;
  }
}

/// Everything that prevents a site from being published (empty = ready).
/// Pages and sections are the site's own content.
string[] publishBlockers(const ref PortalSite site, const PortalPage[] pages, const PortalSection[] sections) {
  string[] blockers;
  if (site.status == SiteStatus.archived)
    blockers ~= "An archived site cannot be published — restore it first";
  if (site.name.length == 0)
    blockers ~= "The site needs a name";

  size_t visiblePages;
  foreach (p; pages) {
    if (p.siteId != site.id || !p.visible)
      continue;
    visiblePages++;
    if (!sections.any!(s => s.pageId == p.id && s.visible))
      blockers ~= "Page '" ~ p.name ~ "' has no visible section";
  }
  if (visiblePages == 0)
    blockers ~= "The site needs at least one visible page";
  return blockers;
}

///
unittest {
  assert(canTransition(SiteStatus.draft, SiteStatus.published));
  assert(canTransition(SiteStatus.published, SiteStatus.published)); // re-publish = new version
  assert(!canTransition(SiteStatus.archived, SiteStatus.published));
  assert(!canTransition(SiteStatus.draft, SiteStatus.unpublished));
  assert(canTransition(SiteStatus.archived, SiteStatus.draft));

  auto site = PortalSite(TenantId("t"));
  site.name = "Sales";
  assert(publishBlockers(site, null, null) == ["The site needs at least one visible page"]);

  auto page = PortalPage(TenantId("t"));
  page.siteId = site.id;
  page.name = "Home";
  assert(publishBlockers(site, [page], null) == ["Page 'Home' has no visible section"]);

  auto section = PortalSection(TenantId("t"));
  section.pageId = page.id;
  assert(publishBlockers(site, [page], [section]).length == 0);
}
