/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.manage.groups;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.group;
import uim.platform.workzone.domain.ports.repositories.groups;
import uim.platform.workzone.application.dto;

class ManageGroupsUseCase : UIMUseCase {
  private GroupRepository repo;

  this(GroupRepository repo) {
    this.repo = repo;
  }

  CommandResult createGroup(CreateGroupRequest req) {
    if (req.name.length == 0)
      return CommandResult("", "Group name is required");

    auto now = Clock.currStdTime();
    auto g = Group();
    g.id = randomUUID();
    g.tenantId = req.tenantId;
    g.name = req.name;
    g.description = req.description;
    g.groupType = req.groupType;
    g.active = true;
    g.createdAt = now;
    g.updatedAt = now;

    repo.save(g);
    return CommandResult(g.id, "");
  }

  Group* getGroup(GroupId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Group[] listGroups(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateGroup(UpdateGroupRequest req) {
    auto g = repo.findById(req.id, req.tenantId);
    if (g is null)
      return CommandResult("", "Group not found");

    if (req.name.length > 0)
      g.name = req.name;
    if (req.description.length > 0)
      g.description = req.description;
    g.active = req.active;
    g.updatedAt = Clock.currStdTime();

    repo.update(*g);
    return CommandResult(g.id, "");
  }

  CommandResult deleteGroup(GroupId tenantId, id tenantId) {
    auto g = repo.findById(tenantId, id);
    if (g is null)
      return CommandResult("", "Group not found");

    repo.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
