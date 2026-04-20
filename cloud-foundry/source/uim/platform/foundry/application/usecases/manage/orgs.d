/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.orgs;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.organization;

// // import uim.platform.foundry.domain.ports.repositories.org;
// // import uim.platform.foundry.domain.ports.repositories.space;
// import uim.platform.foundry.domain.ports;
// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class ManageOrgsUseCase { // TODO: UIMUseCase {
  private OrgRepository repo;
  private SpaceRepository spaceRepo;

  this(OrgRepository repo, SpaceRepository spaceRepo) {
    this.repo = repo;
    this.spaceRepo = spaceRepo;
  }

  CommandResult createOrg(CreateOrgRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Organization name is required");

    // Unique name per tenant
    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult(false, "", "Organization with this name already exists");

    auto now = Clock.currStdTime();
    auto org = Organization();
    org.id = randomUUID();
    org.tenantId = req.tenantId;
    org.name = req.name;
    org.status = OrgStatus.active;
    org.memoryQuotaMb = req.memoryQuotaMb > 0 ? req.memoryQuotaMb : 10_240;
    org.instanceMemoryLimitMb = req.instanceMemoryLimitMb > 0 ? req.instanceMemoryLimitMb : 2048;
    org.totalRoutes = req.totalRoutes > 0 ? req.totalRoutes : 1000;
    org.totalServices = req.totalServices > 0 ? req.totalServices : 100;
    org.totalAppInstances = req.totalAppInstances;
    org.createdBy = req.createdBy;
    org.createdAt = now;
    org.updatedAt = now;

    repo.save(org);
    return CommandResult(org.id, "");
  }

  Organization* getOrg(OrgId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Organization[] listOrgs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateOrg(UpdateOrgRequest req) {
    if (req.id.isEmpty)
      return CommandResult(false, "", "Organization ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult(false, "", "Organization not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    updated.status = req.status;
    if (req.memoryQuotaMb > 0)
      updated.memoryQuotaMb = req.memoryQuotaMb;
    if (req.instanceMemoryLimitMb > 0)
      updated.instanceMemoryLimitMb = req.instanceMemoryLimitMb;
    if (req.totalRoutes > 0)
      updated.totalRoutes = req.totalRoutes;
    if (req.totalServices > 0)
      updated.totalServices = req.totalServices;
    updated.totalAppInstances = req.totalAppInstances;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  CommandResult suspendOrg(OrgId tenantId, id tenantId) {
    auto org = repo.findById(tenantId, id);
    if (org is null)
      return CommandResult(false, "", "Organization not found");
    if (org.status == OrgStatus.suspended)
      return CommandResult(false, "", "Organization is already suspended");

    org.status = OrgStatus.suspended;
    org.updatedAt = Clock.currStdTime();
    repo.update(*org);
    return CommandResult(true, id.toString, "");
  }

  CommandResult activateOrg(OrgId tenantId, id tenantId) {
    auto org = repo.findById(tenantId, id);
    if (org is null)
      return CommandResult(false, "", "Organization not found");
    if (org.status == OrgStatus.active)
      return CommandResult(false, "", "Organization is already active");

    org.status = OrgStatus.active;
    org.updatedAt = Clock.currStdTime();
    repo.update(*org);
    return CommandResult(true, id.toString, "");
  }

  CommandResult deleteOrg(OrgId tenantId, id tenantId) {
    auto existing = repo.findById(tenantId, id);
    if (existing is null)
      return CommandResult(false, "", "Organization not found");

    // Cascade: remove all spaces in this org
    spaceRepo.removeByOrg(tenantId, id);
    repo.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
