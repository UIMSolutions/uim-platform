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



 
import uim.platform.portal.domain.types;
import uim.platform.portal.application.dto;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManagePagesUseCase { // TODO: UIMUseCase {
  private PageRepository pageRepo;
  private SiteRepository siteRepo;

  this(PageRepository pageRepo, SiteRepository siteRepo) {
    this.pageRepo = pageRepo;
    this.siteRepo = siteRepo;
  }

  PageResponse createPage(CreatePageRequest req) {
    if (req.title.length == 0)
      return PageResponse(PageResponseId(""), "Page title is required");

    if (!siteRepo.existsById(req.siteId))
      return PageResponse(PageResponseId(""), "Site not found");

    Page page;
    page.initEntity(req.tenantId);
    with (page) {
      siteId = req.siteId;
      title = req.title;
      description = req.description;
      alias_ = req.alias_;
      layout = req.layout;
      allowedRoleIds = req.allowedRoleIds.map!(r => RoleId(r)).array.toJson;
      sortOrder = req.sortOrder;
      visible = req.visible;
    }

    pageRepo.save(page);

    // Add page to site
    if (siteRepo.existsById(req.siteId)) {
      auto site = siteRepo.findById(req.siteId);
      site.pageIds ~= page.id;
      site.updatedAt = currentTimestamp();
      siteRepo.update(site);
    }

    return PageResponse(page.id.value, "");
  }

  Page getPage(PageId id) {
    return pageRepo.findById(tenantId, id);
  }

  Page[] listPages(SiteId siteId, size_t offset = 0, size_t limit = 100) {
    return pageRepo.findBySite(siteId, offset, limit);
  }

  CommandResult updatePage(UpdatePageRequest req) {
    if (!pageRepo.existsById(req.pageId))
      return CommandResult(false, "", "Page not found");

    auto page = pageRepo.findById(req.pageId);
    with (page) {
      title = req.title.length > 0 ? req.title : title;
      description = req.description;
      alias_ = req.alias_.length > 0 ? req.alias_ : alias_;
      layout = req.layout;
      allowedRoleIds = req.allowedRoleIds.map!(r => RoleId(r)).array.toJson;
      sortOrder = req.sortOrder;
      visible = req.visible;
      updatedAt = currentTimestamp();
    }
    pageRepo.update(page);
    return CommandResult(true, page.id.value, "Page updated successfully.");
  }

  CommandResult deletePage(PageId pageId, SiteId siteId) {
    if (!pageRepo.existsById(pageId))
      return CommandResult(false, "", "Page not found");

    pageRepo.remove(pageId);

    // Remove from site
    if (siteRepo.existsById(siteId)) {
      auto site = siteRepo.findById(siteId);
      site.pageIds = site.pageIds.filter!(p => p != pageId).array.toJson;
      site.updatedAt = currentTimestamp();
      siteRepo.update(site);
    }

    return CommandResult(true, pageId.value, "Page deleted successfully.");
  }
}
