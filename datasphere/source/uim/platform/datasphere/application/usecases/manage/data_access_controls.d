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



import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageDataAccessControlsUseCase { // TODO: UIMUseCase {
  private DataAccessControlRepository repo;

  this(DataAccessControlRepository repo) {
    this.repo = repo;
  }

  CommandResult createDataAccessControl(CreateDataAccessControlRequest r) {
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

  DataAccessControl getDataAccessControl(SpaceId spaceId, DataAccessControlId id) {
    return repo.findById(spaceId, id);
  }

  DataAccessControl[] listDataAccessControls(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult updateDataAccessControl(UpdateDataAccessControlRequest r) {
    auto control = repo.findById(r.spaceId, r.controlId);
    if (control.isNull)
      return CommandResult(false, "", "Data access control not found");

    control.name = r.name;
    control.description = r.description;
    control.targetViewIds = r.targetViewIds;
    control.assignedUserIds = r.assignedUserIds;
    control.isEnabled = r.isEnabled;

    import core.time : MonoTime;
    control.updatedAt = MonoTime.currTime.ticks;

    repo.update(control);
    return CommandResult(true, control.id.value, "");
  }

  CommandResult deleteDataAccessControl(SpaceId spaceId, DataAccessControlId id) {
    auto control = repo.findById(spaceId, id);
    if (control.isNull)
      return CommandResult(false, "", "Data access control not found");

    repo.remove(control);
    return CommandResult(true, control.id.value, "");
  }
}
