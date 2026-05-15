/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.sites;

// import uim.platform.portal.domain.entities.site;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.sites;
// import uim.platform.portal.domain.services.site_publisher;
// import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageSitesUseCase { // TODO: UIMUseCase {
  private SiteRepository siteRepo;

  this(SiteRepository siteRepo) {
    this.siteRepo = siteRepo;
  }

  CommandResult createSite(CreateSiteRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Site name is required");

    if (req.alias_.length > 0) {
      auto existing = siteRepo.findByAlias(req.tenantId, req.alias_);
      if (existing != Site.init)
        return CommandResult(false, "", "Site alias already exists");
    }

    Site site;
    site.initEntity(req.tenantId, req.createdBy);

    site.name = req.name;
    site.description = req.description;
    site.alias_ = req.alias_;
    site.status = SiteStatus.draft;
    site.themeId = req.themeId;
    site.settings = req.settings;

    siteRepo.save(site);
    return CommandResult(true, site.id.value, "Site created successfully.");
  }

  Site getSite(SiteId id) {
    return siteRepo.findById(tenantId, id);
  }

  Site[] listSites(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return siteRepo.findByTenant(tenantId, offset, limit);
  }

  Site[] listSitesByStatus(TenantId tenantId, SiteStatus status, size_t offset = 0, size_t limit = 100) {
    return siteRepo.findByStatus(tenantId, status, offset, limit);
  }

  CommandResult updateSite(UpdateSiteRequest req) {
    auto site = siteRepo.findById(req.siteId);
    if (site == Site.init)
      return CommandResult(false, "", "Site not found");

    site.name = req.name.length > 0 ? req.name : site.name;
    site.description = req.description;
    site.alias_ = req.alias_.length > 0 ? req.alias_ : site.alias_;
    site.themeId = req.themeId.length > 0 ? req.themeId : site.themeId;
    site.settings = req.settings;
    site.updatedAt = Clock.currStdTime();
    siteRepo.update(site);
    return CommandResult(true, site.id.value, "Site updated successfully.");
  }

  CommandResult publishSite(SiteId id) {
    auto site = siteRepo.findById(tenantId, id);
    if (site == Site.init)
      return CommandResult(false, "", "Site not found");

    auto result = validateForPublish(site);
    if (!result.valid) {
      // import std.algorithm : joiner;

      return CommandResult(false, "", result.errors.joiner("; ").to!string);
    }

    site.status = SiteStatus.published;
    site.updatedAt = Clock.currStdTime();
    siteRepo.update(site);
    return CommandResult(true, site.id.value, "Site published successfully.");
  }

  CommandResult unpublishSite(SiteId id) {
    auto site = siteRepo.findById(tenantId, id);
    if (site == Site.init)
      return CommandResult(false, "", "Site not found");

    site.status = SiteStatus.unpublished;
    site.updatedAt = Clock.currStdTime();
    siteRepo.update(site);
    return CommandResult(true, site.id.value, "Site unpublished successfully.");
  }

  CommandResult archiveSite(SiteId id) {
    auto site = siteRepo.findById(tenantId, id);
    if (site == Site.init)
      return CommandResult(false, "", "Site not found");

    site.status = SiteStatus.archived;
    site.updatedAt = Clock.currStdTime();
    siteRepo.update(site);
    return CommandResult(true, site.id.value, "Site archived successfully.");
  }

  CommandResult deleteSite(SiteId id) {
    auto site = siteRepo.findById(tenantId, id);
    if (site == Site.init)
      return CommandResult(false, "", "Site not found");

    siteRepo.removeById(id);
    return CommandResult(true, site.id.value, "Site deleted successfully.");
  }
}
