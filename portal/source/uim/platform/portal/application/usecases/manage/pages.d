/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage_pages;

import uim.platform.portal.domain.entities.page;
import uim.platform.portal.domain.entities.site;
import uim.platform.portal.domain.types;
import uim.platform.portal.domain.ports.repositories.pages;
import uim.platform.portal.domain.ports.repositories.sites;
import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : filter, canFind;
// import std.array : array;

class ManagePagesUseCase
{
  private PageRepository pageRepo;
  private SiteRepository siteRepo;

  this(PageRepository pageRepo, SiteRepository siteRepo)
  {
    this.pageRepo = pageRepo;
    this.siteRepo = siteRepo;
  }

  PageResponse createPage(CreatePageRequest req)
  {
    if (req.title.length == 0)
      return PageResponse("", "Page title is required");

    auto site = siteRepo.findById(req.siteId);
    if (site == Site.init)
      return PageResponse("", "Site not found");

    auto now = Clock.currStdTime();
    auto id = randomUUID().toString();
    auto page = Page(id, req.siteId, req.tenantId, req.title, req.description,
        req.alias_, req.layout, [], // sectionIds
        req.allowedRoleIds, req.sortOrder, req.visible, now, now,);
    pageRepo.save(page);

    // Add page to site
    site.pageIds ~= id;
    site.updatedAt = now;
    siteRepo.update(site);

    return PageResponse(id, "");
  }

  Page getPage(PageId id)
  {
    return pageRepo.findById(id);
  }

  Page[] listPages(SiteId siteId, uint offset = 0, uint limit = 100)
  {
    return pageRepo.findBySite(siteId, offset, limit);
  }

  string updatePage(UpdatePageRequest req)
  {
    auto page = pageRepo.findById(req.pageId);
    if (page == Page.init)
      return "Page not found";

    page.title = req.title.length > 0 ? req.title : page.title;
    page.description = req.description;
    page.alias_ = req.alias_.length > 0 ? req.alias_ : page.alias_;
    page.layout = req.layout;
    page.allowedRoleIds = req.allowedRoleIds;
    page.sortOrder = req.sortOrder;
    page.visible = req.visible;
    page.updatedAt = Clock.currStdTime();
    pageRepo.update(page);
    return "";
  }

  string deletePage(PageId pageId, SiteId siteId)
  {
    auto page = pageRepo.findById(pageId);
    if (page == Page.init)
      return "Page not found";

    pageRepo.remove(pageId);

    // Remove from site
    auto site = siteRepo.findById(siteId);
    if (site != Site.init)
    {
      site.pageIds = site.pageIds.filter!(p => p != pageId).array;
      site.updatedAt = Clock.currStdTime();
      siteRepo.update(site);
    }

    return "";
  }
}
