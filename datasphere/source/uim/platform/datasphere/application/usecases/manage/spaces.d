/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.spaces;

// import uim.platform.datasphere.domain.entities.space;
// import uim.platform.datasphere.domain.ports.repositories.spaces;
// import uim.platform.datasphere.domain.services.space_validator;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
class ManageSpacesUseCase { // TODO: UIMUseCase {
  private SpaceRepository repo;

  this(SpaceRepository repo) {
    this.repo = repo;
  }

  CommandResult createSpace(CreateSpaceRequest r) {
    auto err = SpaceValidator.validate(r.spaceId, r.name);
    if (err.length > 0)
      return CommandResult(false, "", err);

    auto existing = repo.findById(r.spaceId);
    if (!existing.isNull)
      return CommandResult(false, "", "Space already exists");

    Space s;
    s.initEntity(r.tenantId);

    s.id = r.spaceId;
    s.name = r.name;
    s.description = r.description;
    s.businessName = r.businessName;
    s.priority = r.priority;

    repo.save(s);
    return CommandResult(true, s.id.value, "");
  }

  Space getSpace(SpaceId id) {
    return repo.findById(tenantId, id);
  }

  Space[] listSpaces(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateSpace(UpdateSpaceRequest r) {
    auto existing = repo.findById(r.spaceId);
    if (existing.isNull)
      return CommandResult(false, "", "Space not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.businessName = r.businessName;
    existing.priority = r.priority;

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteSpace(SpaceId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Space not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countSpaces(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
