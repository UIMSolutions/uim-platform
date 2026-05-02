/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.spaces;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.space;

// // import uim.platform.foundry.domain.ports.repositories.space;
// // import uim.platform.foundry.domain.ports.repositories.org;
// import uim.platform.foundry.domain.ports;
// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class ManageSpacesUseCase { // TODO: UIMUseCase {
  private ISpaceRepository repo;
  private IOrgRepository orgRepo;

  this(ISpaceRepository repo, IOrgRepository orgRepo) {
    this.repo = repo;
    this.orgRepo = orgRepo;
  }

  CommandResult createSpace(CreateSpaceRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.orgId.isEmpty)
      return CommandResult(false, "", "Organization ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Space name is required");

    // Validate org exists
    auto org = orgRepo.findById(req.orgId, req.tenantId);
    if (org.isNull)
      return CommandResult(false, "", "Organization not found");
    if (org.status == OrgStatus.suspended)
      return CommandResult(false, "", "Organization is suspended");

    // Unique name within org
    auto existing = repo.findByName(req.orgId, req.tenantId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Space with this name already exists in org");

    auto now = Clock.currStdTime();
    auto space = Space();
    space.id = randomUUID();
    space.orgId = req.orgId;
    space.tenantId = req.tenantId;
    space.name = req.name;
    space.status = SpaceStatus.active;
    space.allowSsh = req.allowSsh;
    space.createdBy = req.createdBy;
    space.createdAt = now;
    space.updatedAt = now;

    repo.save(space);
    return CommandResult(true, space.id.value, "");
  }

  Space* getSpace(TenantId tenantId, SpaceId spaceId) {
    return repo.findById(tenantId, spaceId);
  }

  Space[] listSpaces(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Space[] listByOrg(TenantId tenantId, OrgId orgId) {
    return repo.findByOrg(tenantId, orgId);
  }

  CommandResult updateSpace(UpdateSpaceRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Space ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.id);
    if (existing.isNull)
      return CommandResult(false, "", "Space not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    updated.status = req.status;
    updated.allowSsh = req.allowSsh;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(true, updated.id.value, "");
  }

  CommandResult deleteSpace(TenantId tenantId, SpaceId id) {
    auto space = repo.findById(tenantId, id);
    if (space.isNull)
      return CommandResult(false, "", "Space not found");

    repo.remove(space);
    return CommandResult(true, space.id.value, "");
  }
}
