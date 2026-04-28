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
  private IOrgRepository orgs;
  private ISpaceRepository spaces;

  this(IOrgRepository orgs, ISpaceRepository spaces) {
    this.orgs = orgs;
    this.spaces = spaces;
  }

  CommandResult createOrg(CreateOrgRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Organization name is required");

    // Unique name per tenant
    if (orgs.existsByName(req.tenantId, req.name))
      return CommandResult(false, "", "Organization with this name already exists");

    auto org = Organization();
    org.initEntity(req.tenantId, req.createdBy);

    org.name = req.name;
    org.status = OrgStatus.active;
    org.memoryQuotaMb = req.memoryQuotaMb > 0 ? req.memoryQuotaMb : 10_240;
    org.instanceMemoryLimitMb = req.instanceMemoryLimitMb > 0 ? req.instanceMemoryLimitMb : 2048;
    org.totalRoutes = req.totalRoutes > 0 ? req.totalRoutes : 1000;
    org.totalServices = req.totalServices > 0 ? req.totalServices : 100;
    org.totalAppInstances = req.totalAppInstances;

    orgs.save(org);
    return CommandResult(true, org.id.toString, "");
  }

  Organization getOrg(TenantId tenantId, OrgId id) {
    return orgs.findById(tenantId, id);
  }

  Organization[] listOrgs(TenantId tenantId) {
    return orgs.findByTenant(tenantId);
  }

  CommandResult updateOrg(UpdateOrgRequest req) {
    if (req.id.isEmpty)
      return CommandResult(false, "", "Organization ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto org = orgs.findById(req.tenantId, req.id);
    if (org.isNull)
      return CommandResult(false, "", "Organization not found");

    auto updated = org; 
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

    orgs.update(updated);
    return CommandResult(true, updated.id.toString, "");
  }

  CommandResult suspendOrg(TenantId tenantId, OrgId id) {
    auto org = orgs.findById(tenantId, id);
    if (org.isNull)
      return CommandResult(false, "", "Organization not found");
    if (org.status == OrgStatus.suspended)
      return CommandResult(false, "", "Organization is already suspended");

    org.status = OrgStatus.suspended;
    org.updatedAt = Clock.currStdTime();
    orgs.update(org);
    return CommandResult(true, id.toString, "");
  }

  CommandResult activateOrg(TenantId tenantId, OrgId id) {
    auto org = orgs.findById(tenantId, id);
    if (org.isNull)
      return CommandResult(false, "", "Organization not found");

    if (org.status == OrgStatus.active)
      return CommandResult(false, "", "Organization is already active");

    org.status = OrgStatus.active;
    org.updatedAt = Clock.currStdTime();
    orgs.update(org);
    return CommandResult(true, id.toString, "");
  }

  CommandResult deleteOrg(TenantId tenantId, OrgId orgId) {
    auto org = orgs.findById(tenantId, orgId);
    if (org.isNull)
      return CommandResult(false, "", "Organization not found");

    // Cascade: remove all spaces in this org
    spaces.removeByOrg(tenantId, orgId);
    orgs.remove(org);
    return CommandResult(true, org.id.toString, "");
  }
}
