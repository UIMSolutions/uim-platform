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


// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageSitesUseCase { // TODO: UIMUseCase {
  private SiteRepository siteRepo;

  this(SiteRepository siteRepo) {
    this.siteRepo = siteRepo;
  }

  CommandResult createSite(CreateSiteRequest req) {
    if (req.name.isEmpty)
      return CommandResult(false, "", "Site name is required");

    if (req.alias_.length > 0) {
      if (siteRepo.existsByAlias(req.tenantId, req.alias_))
        return CommandResult(false, "", "Site alias already exists");
    }

    auto site = Site(req.tenantId); //, UserId("test-user"));
    site.name = req.name;
    site.description = req.description;
    site.alias_ = req.alias_;
    site.status = SiteStatus.draft;
    site.themeId = req.themeId;
    site.settings = req.settings;

    siteRepo.save(site);
    return CommandResult(true, site.id.value, "Site created successfully.");
  }

  Site getSite(TenantId tenantId, SiteId id) {
    return siteRepo.findById(tenantId, id);
  }

  Site[] listSites(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return siteRepo.findByTenant(tenantId, offset, limit);
  }

  Site[] listSites(TenantId tenantId, SiteStatus status, size_t offset = 0, size_t limit = 100) {
    return siteRepo.findByStatus(tenantId, status, offset, limit);
  }

  CommandResult updateSite(UpdateSiteRequest req) {
    auto site = siteRepo.findById(req.tenantId, req.siteId);
    if (site.isNull)
      return CommandResult(false, "", "Site not found");

    site.name = req.name.length > 0 ? req.name : site.name;
    site.description = req.description;
    site.alias_ = req.alias_.length > 0 ? req.alias_ : site.alias_;
    site.themeId = req.themeId.length > 0 ? req.themeId : site.themeId;
    site.settings = req.settings;
    site.updatedAt = currentTimestamp();
    siteRepo.update(site);
    return CommandResult(true, site.id.value, "Site updated successfully.");
  }

  CommandResult publishSite(TenantId tenantId, SiteId id) {
    auto site = siteRepo.findById(tenantId, id);
    if (site.isNull)
      return CommandResult(false, "", "Site not found");

    auto result = validateForPublish(site);
    if (!result.valid) {
      // import std.algorithm : joiner;

      return CommandResult(false, "", result.messages.joiner("; ").to!string);
    }

    site.status = SiteStatus.published;
    site.updatedAt = currentTimestamp();
    siteRepo.update(site);
    return CommandResult(true, site.id.value, "Site published successfully.");
  }

  CommandResult unpublishSite(TenantId tenantId, SiteId id) {
    auto site = siteRepo.findById(tenantId, id);
    if (site.isNull)
      return CommandResult(false, "", "Site not found");

    site.status = SiteStatus.unpublished;
    site.updatedAt = currentTimestamp();
    siteRepo.update(site);
    return CommandResult(true, site.id.value, "Site unpublished successfully.");
  }

  CommandResult archiveSite(TenantId tenantId, SiteId id) {
    auto site = siteRepo.findById(tenantId, id);
    if (site.isNull)
      return CommandResult(false, "", "Site not found");

    site.status = SiteStatus.archived;
    site.updatedAt = currentTimestamp();
    siteRepo.update(site);
    return CommandResult(true, site.id.value, "Site archived successfully.");
  }

  CommandResult deleteSite(TenantId tenantId, SiteId id) {
    auto site = siteRepo.findById(tenantId, id);
    if (site.isNull)
      return CommandResult(false, "", "Site not found");

    siteRepo.remove(site);
    return CommandResult(true, site.id.value, "Site deleted successfully.");
  }
}
