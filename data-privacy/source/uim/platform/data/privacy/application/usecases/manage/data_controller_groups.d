/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.data_controller_groups;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageDataControllerGroupsUseCase { // TODO: UIMUseCase {
  private DataControllerGroupRepository repo;

  this(DataControllerGroupRepository repo) {
    this.repo = repo;
  }

  CommandResult createGroup(CreateDataControllerGroupRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    DataControllerGroup g;
    g.initEntity(req.tenantId);

    g.name = req.name;
    g.description = req.description;
    g.controllerIds = req.controllerIds;
    g.isActive = true;

    repo.save(g);
    return CommandResult(true, g.id.value, "");
  }

  DataControllerGroup getGroup(TenantId tenantId, DataControllerGroupId id) {
    return repo.findById(tenantId, id);
  }

  DataControllerGroup[] listGroups(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateGroup(UpdateDataControllerGroupRequest req) {
    auto g = repo.findById(req.tenantId, req.id);
    if (g.isNull)
      return CommandResult(false, "", "Data controller group not found");

    if (req.name.length > 0) g.name = req.name;
    if (req.description.length > 0) g.description = req.description;
    if (req.controllerIds.length > 0) g.controllerIds = req.controllerIds;
    g.updatedAt = currentTimestamp();

    repo.update(g);
    return CommandResult(true, g.id.value, "");
  }

  CommandResult deleteGroup(TenantId tenantId, DataControllerGroupId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Data controller group not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
