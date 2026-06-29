/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.groups;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.group;
// import uim.platform.workzone.domain.ports.repositories.groups;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class ManageGroupsUseCase { // TODO: UIMUseCase {
  private GroupRepository repo;

  this(GroupRepository repo) {
    this.repo = repo;
  }

  CommandResult createGroup(CreateGroupRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "WZGroup name is required");

    auto now = currentTimestamp();
    WZGroup g;
    g.initEntity(req.tenantId);
    
    g.name = req.name;
    g.description = req.description;
    // TODO: g.groupType = req.groupType;
    g.active = true;

    repo.save(g);
    return CommandResult(true, g.id.value, "");
  }

  WZGroup getGroup(TenantId tenantId, GroupId id) {
    return repo.findById(tenantId, id);
  }

  WZGroup[] listGroups(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateGroup(UpdateGroupRequest req) {
    auto g = repo.findById(req.tenantId, req.id);
    if (g.isNull)
      return CommandResult(false, "", "WZGroup not found");

    if (req.name.length > 0)
      g.name = req.name;
    if (req.description.length > 0)
      g.description = req.description;
    g.active = req.active;
    g.updatedAt = currentTimestamp();

    repo.update(g);
    return CommandResult(true, g.id.value, "");
  }

  CommandResult deleteGroup(TenantId tenantId, GroupId id) {
    auto g = repo.findById(tenantId, id);
    if (g.isNull)
      return CommandResult(false, "", "WZGroup not found");

    repo.remove(g);
    return CommandResult(true, g.id.value, "");
  }
}
