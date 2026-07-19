/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.sites;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.site;
// import uim.platform.workzone.domain.ports.repositories.sites;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageSitesUseCase { // TODO: UIMUseCase {
  private SiteRepository repo;

  this(SiteRepository repo) {
    this.repo = repo;
  }

  CommandResult createSite(CreateSiteRequest req) {
    if (req.name.isEmpty)
      return CommandResult(false, "", "Site name is required");

    auto s = Site(req.tenantId);
    s.name = req.name;
    s.description = req.description;
    s.alias_ = req.alias_;
    s.status = SiteStatus.draft;
    s.themeId = req.themeId;
    s.settings = req.settings;

    repo.save(s);
    return CommandResult(true, s.id.value, "");
  }

  Site getSite(TenantId tenantId, SiteId id) {
    return repo.findById(tenantId, id);
  }

  Site[] listSites(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateSite(UpdateSiteRequest req) {
    auto s = repo.findById(req.tenantId, req.id);
    if (s.isNull)
      return CommandResult(false, "", "Site not found");

    if (req.name.length > 0)
      s.name = req.name;
    if (req.description.length > 0)
      s.description = req.description;
    if (req.themeId.length > 0)
      s.themeId = req.themeId;
    s.settings = req.settings;
    s.updatedAt = currentTimestamp();

    repo.update(s);
    return CommandResult(true, s.id.value, "");
  }

  CommandResult deleteSite(TenantId tenantId, SiteId id) {
    auto s = repo.findById(tenantId, id);
    if (s.isNull)
      return CommandResult(false, "", "Site not found");

    repo.remove(s);
    return CommandResult(true, s.id.value, "");
  }
}
