/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.data_access_controls;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.data_access_control;
// import uim.platform.datasphere.domain.ports.repositories.data_access_controls;
// import uim.platform.datasphere.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageDataAccessControlsUseCase { // TODO: UIMUseCase {
  private DataAccessControlRepository repo;

  this(DataAccessControlRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDataAccessControlRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Data access control name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    DataAccessControl dac;
    dac.id = r.controlId;
    dac.tenantId = r.tenantId;
    dac.spaceId = r.spaceId;
    dac.name = r.name;
    dac.description = r.description;
    dac.targetViewIds = r.targetViewIds;
    dac.assignedUserIds = r.assignedUserIds;
    dac.isEnabled = true;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    dac.createdAt = now;
    dac.updatedAt = now;

    repo.save(dac);
    return CommandResult(true, dac.id.value, "");
  }

  DataAccessControl getById(SpaceId spaceId, DataAccessControlId id) {
    return repo.findById(spaceId, id);
  }

  DataAccessControl[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult update(UpdateDataAccessControlRequest r) {
    auto existing = repo.findById(r.spaceId, r.controlId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Data access control not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.targetViewIds = r.targetViewIds;
    existing.assignedUserIds = r.assignedUserIds;
    existing.isEnabled = r.isEnabled;

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult remove(SpaceId spaceId, DataAccessControlId id) {
    auto existing = repo.findById(spaceId, id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Data access control not found");

    repo.remove(spaceId, id);
    return CommandResult(true, id.value, "");
  }
}
