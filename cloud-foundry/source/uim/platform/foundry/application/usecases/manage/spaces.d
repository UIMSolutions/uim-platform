/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.spaces;


// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.space;
// import uim.platform.foundry.domain.ports.repositories.space;
// import uim.platform.foundry.domain.ports.repositories.org;

// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

// mixin(ShowModule!());

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
    auto org = orgRepo.findById(req.tenantId, req.orgId);
    if (org.isNull)
      return CommandResult(false, "", "Organization not found");
    if (org.status == OrgStatus.suspended)
      return CommandResult(false, "", "Organization is suspended");

    // Unique name within org
    if (repo.existsByName(req.tenantId, req.orgId, req.name))
      return CommandResult(false, "", "Space with this name already exists in org");

    auto space = Space();
    space.initEntity(req.tenantId, req.createdBy);
    space.orgId = req.orgId;
    space.name = req.name;
    space.status = SpaceStatus.active;
    space.allowSsh = req.allowSsh;

    repo.save(space);
    return CommandResult(true, space.id.value, "");
  }

  Space getSpace(TenantId tenantId, SpaceId spaceId) {
    return repo.findById(tenantId, spaceId);
  }

  Space[] listSpaces(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Space[] listByOrg(TenantId tenantId, OrgId orgId) {
    return repo.findByOrg(tenantId, orgId);
  }

  CommandResult updateSpace(UpdateSpaceRequest req) {
    if (req.spaceId.isNull)
      return CommandResult(false, "", "Space ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto space = repo.findById(req.tenantId, req.spaceId);
    if (space.isNull)
      return CommandResult(false, "", "Space not found");

    if (req.name.length > 0)
      space.name = req.name;
    space.status = req.status;
    space.allowSsh = req.allowSsh;
    space.updatedAt = currentTimestamp();

    repo.update(space);
    return CommandResult(true, space.id.value, "");
  }

  CommandResult deleteSpace(TenantId tenantId, SpaceId id) {
    auto space = repo.findById(tenantId, id);
    if (space.isNull)
      return CommandResult(false, "", "Space not found");

    repo.remove(space);
    return CommandResult(true, space.id.value, "");
  }
}
