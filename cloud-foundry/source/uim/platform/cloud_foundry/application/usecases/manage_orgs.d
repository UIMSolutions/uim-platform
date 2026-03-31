module uim.platform.cloud_foundry.application.usecases.manage_orgs;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.organization;
import uim.platform.cloud_foundry.domain.ports.org_repository;
import uim.platform.cloud_foundry.domain.ports.space_repository;
import application.dto;

class ManageOrgsUseCase
{
  private OrgRepository repo;
  private SpaceRepository spaceRepo;

  this(OrgRepository repo, SpaceRepository spaceRepo)
  {
    this.repo = repo;
    this.spaceRepo = spaceRepo;
  }

  CommandResult createOrg(CreateOrgRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Organization name is required");

    // Unique name per tenant
    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Organization with this name already exists");

    auto now = Clock.currStdTime();
    auto org = Organization();
    org.id = randomUUID().toString();
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

  Organization* getOrg(OrgId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  Organization[] listOrgs(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateOrg(UpdateOrgRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "Organization ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Organization not found");

    auto updated = *existing;
    if (req.name.length > 0) updated.name = req.name;
    updated.status = req.status;
    if (req.memoryQuotaMb > 0) updated.memoryQuotaMb = req.memoryQuotaMb;
    if (req.instanceMemoryLimitMb > 0) updated.instanceMemoryLimitMb = req.instanceMemoryLimitMb;
    if (req.totalRoutes > 0) updated.totalRoutes = req.totalRoutes;
    if (req.totalServices > 0) updated.totalServices = req.totalServices;
    updated.totalAppInstances = req.totalAppInstances;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  CommandResult suspendOrg(OrgId id, TenantId tenantId)
  {
    auto org = repo.findById(id, tenantId);
    if (org is null)
      return CommandResult("", "Organization not found");
    if (org.status == OrgStatus.suspended)
      return CommandResult("", "Organization is already suspended");

    org.status = OrgStatus.suspended;
    org.updatedAt = Clock.currStdTime();
    repo.update(*org);
    return CommandResult(id, "");
  }

  CommandResult activateOrg(OrgId id, TenantId tenantId)
  {
    auto org = repo.findById(id, tenantId);
    if (org is null)
      return CommandResult("", "Organization not found");
    if (org.status == OrgStatus.active)
      return CommandResult("", "Organization is already active");

    org.status = OrgStatus.active;
    org.updatedAt = Clock.currStdTime();
    repo.update(*org);
    return CommandResult(id, "");
  }

  CommandResult deleteOrg(OrgId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Organization not found");

    // Cascade: remove all spaces in this org
    spaceRepo.removeByOrg(id, tenantId);
    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
