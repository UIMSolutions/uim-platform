/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.pages;

// import uim.platform.portal.domain.entities.page;
// import uim.platform.portal.domain.entities.site;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.pages;
// import uim.platform.portal.domain.ports.repositories.sites;
// import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : filter, canFind;
// import std.array : array;
import uim.platform.portal.domain.types;
import uim.platform.portal.application.dto;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManagePagesUseCase : UIMUseCase {
  private PageRepository pageRepo;
  private SiteRepository siteRepo;

  this(PageRepository pageRepo, SiteRepository siteRepo) {
    this.pageRepo = pageRepo;
    this.siteRepo = siteRepo;
  }

  PageResponse createPage(CreatePageRequest req) {
    if (req.title.length == 0)
      return PageResponse("", "Page title is required");

    if (!siteRepo.existsById(req.siteId))
      return PageResponse("", "Site not found");

    auto now = Clock.currStdTime();
    auto id = randomUUID();
    Page page;
    with (page) {
      pageId = id;
      siteId = req.siteId;
      tenantId = req.tenantId;
      title = req.title;
      description = req.description;
      alias_ = req.alias_;
      layout = req.layout;
      allowedRoleIds = req.allowedRoleIds.map!(r => RoleId(r)).array;
      sortOrder = req.sortOrder;
      visible = req.visible;
      createdAt = now;
      updatedAt = now;
    }

    pageRepo.save(page);

    // Add page to site
    if (siteRepo.existsById(req.siteId)) {
      auto site = siteRepo.findById(req.siteId);
      site.pageIds ~= id;
      site.updatedAt = now;
      siteRepo.update(site);
    }

    return PageResponse(id, "");
  }

  Page getPage(PageId id) {
    return pageRepo.findById(id);
  }

  Page[] listPages(SiteId siteId, uint offset = 0, uint limit = 100) {
    return pageRepo.findBySite(siteId, offset, limit);
  }

  string updatePage(UpdatePageRequest req) {
    if (!pageRepo.existsById(req.pageId))
      return "Page not found";

    auto page = pageRepo.findById(req.pageId);
    with (page) {
      title = req.title.length > 0 ? req.title : title;
      description = req.description;
      alias_ = req.alias_.length > 0 ? req.alias_ : alias_;
      layout = req.layout;
      allowedRoleIds = req.allowedRoleIds;
      sortOrder = req.sortOrder;
      visible = req.visible;
      updatedAt = Clock.currStdTime();
    }
    pageRepo.update(page);
    return "";
  }

  string deletePage(PageId pageId, SiteId siteId) {
    if (!pageRepo.existsById(pageId))
      return "Page not found";

    pageRepo.remove(pageId);

    // Remove from site
    if (siteRepo.existsById(siteId)) {
      auto site = siteRepo.findById(siteId);
      site.pageIds = site.pageIds.filter!(p => p != pageId).array;
      site.updatedAt = Clock.currStdTime();
      siteRepo.update(site);
    }

    return "";
  }
}
