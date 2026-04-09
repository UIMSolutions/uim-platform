/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.data_controller_groups;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageDataControllerGroupsUseCase : UIMUseCase {
  private DataControllerGroupRepository repo;

  this(DataControllerGroupRepository repo) {
    this.repo = repo;
  }

  CommandResult createGroup(CreateDataControllerGroupRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Name is required");

    auto now = Clock.currStdTime();
    auto g = DataControllerGroup();
    g.id = randomUUID();
    g.tenantId = req.tenantId;
    g.name = req.name;
    g.description = req.description;
    g.controllerIds = req.controllerIds;
    g.isActive = true;
    g.createdAt = now;
    g.updatedAt = now;

    repo.save(g);
    return CommandResult(g.id, "");
  }

  DataControllerGroup* getGroup(DataControllerGroupId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  DataControllerGroup[] listGroups(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateGroup(UpdateDataControllerGroupRequest req) {
    auto g = repo.findById(req.id, req.tenantId);
    if (g is null)
      return CommandResult("", "Data controller group not found");

    if (req.name.length > 0) g.name = req.name;
    if (req.description.length > 0) g.description = req.description;
    if (req.controllerIds.length > 0) g.controllerIds = req.controllerIds;
    g.updatedAt = Clock.currStdTime();

    repo.update(*g);
    return CommandResult(g.id, "");
  }

  void deleteGroup(DataControllerGroupId tenantId, id tenantId) {
    repo.remove(tenantId, id);
  }
}
