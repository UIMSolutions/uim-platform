/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.spaces;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.space;

// import uim.platform.foundry.domain.ports.repositories.space;
// import uim.platform.foundry.domain.ports.repositories.org;
import uim.platform.foundry.domain.ports;
import uim.platform.foundry.application.dto;

class ManageSpacesUseCase : UIMUseCase {
  private SpaceRepository repo;
  private OrgRepository orgRepo;

  this(SpaceRepository repo, OrgRepository orgRepo) {
    this.repo = repo;
    this.orgRepo = orgRepo;
  }

  CommandResult createSpace(CreateSpaceRequest req) {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.orgId.length == 0)
      return CommandResult("", "Organization ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Space name is required");

    // Validate org exists
    auto org = orgRepo.findById(req.orgId, req.tenantId);
    if (org is null)
      return CommandResult("", "Organization not found");
    if (org.status == OrgStatus.suspended)
      return CommandResult("", "Organization is suspended");

    // Unique name within org
    auto existing = repo.findByName(req.orgId, req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Space with this name already exists in org");

    auto now = Clock.currStdTime();
    auto space = Space();
    space.id = randomUUID().toString();
    space.orgId = req.orgId;
    space.tenantId = req.tenantId;
    space.name = req.name;
    space.status = SpaceStatus.active;
    space.allowSsh = req.allowSsh;
    space.createdBy = req.createdBy;
    space.createdAt = now;
    space.updatedAt = now;

    repo.save(space);
    return CommandResult(space.id, "");
  }

  Space* getSpace(SpaceId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  Space[] listSpaces(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Space[] listByOrg(OrgId orgId, TenantId tenantId) {
    return repo.findByOrg(orgId, tenantId);
  }

  CommandResult updateSpace(UpdateSpaceRequest req) {
    if (req.id.length == 0)
      return CommandResult("", "Space ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Space not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    updated.status = req.status;
    updated.allowSsh = req.allowSsh;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  CommandResult deleteSpace(SpaceId id, TenantId tenantId) {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Space not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
