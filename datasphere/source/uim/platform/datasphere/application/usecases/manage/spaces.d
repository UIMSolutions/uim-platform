/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.spaces;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.space;
import uim.platform.datasphere.domain.ports.repositories.spaces;
import uim.platform.datasphere.domain.services.space_validator;
import uim.platform.datasphere.application.dto;

import uim.platform.service;
import std.conv : to;

class ManageSpacesUseCase { // TODO: UIMUseCase {
  private SpaceRepository repo;

  this(SpaceRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateSpaceRequest r) {
    auto err = SpaceValidator.validate(r.id, r.name);
    if (err.length > 0)
      return CommandResult(false, "", err);

    auto existing = repo.findById(r.id);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Space already exists");

    Space s;
    s.id = r.id;
    s.tenantId = r.tenantId;
    s.name = r.name;
    s.description = r.description;
    s.businessName = r.businessName;
    s.priority = r.priority;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    s.createdAt = now;
    s.modifiedAt = now;

    repo.save(s);
    return CommandResult(true, s.id, "");
  }

  Space getById(SpaceId id) {
    return repo.findById(id);
  }

  Space[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateSpaceRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Space not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.businessName = r.businessName;
    existing.priority = r.priority;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(SpaceId id) {
    auto existing = repo.findById(id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Space not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
