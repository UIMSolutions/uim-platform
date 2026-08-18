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

mixin(ShowModule!()); 

@safe:
class ManageSpacesUseCase {
  protected ISpaceRepository repo;

  this(ISpaceRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createSpace(CreateSpaceRequest r) {
    auto err = SpaceValidator.validate(r.spaceId, r.name);
    if (err.length > 0)
      return UsecaseResult(false, "", err);

    if (repo.existsById(r.tenantId, r.spaceId))
      return UsecaseResult(false, "", "Space already exists");

    auto s = Space(r.tenantId);
    s.id = r.spaceId;
    s.name = r.name;
    s.description = r.description;
    s.businessName = r.businessName;
    s.priority = r.priority;

    repo.save(s);
    return UsecaseResult(true, s.id.value, "");
  }

  Space getSpace(TenantId tenantId, SpaceId id) {
    return repo.findById(tenantId, id);
  }

  Space[] listSpaces(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateSpace(UpdateSpaceRequest r) {
    auto existing = repo.findById(r.tenantId, r.spaceId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Space not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.businessName = r.businessName;
    existing.priority = r.priority;

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  UsecaseResult deleteSpace(TenantId tenantId, SpaceId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Space not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }

  size_t countSpaces(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
