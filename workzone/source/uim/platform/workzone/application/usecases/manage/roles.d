/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.roles;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.role;
import uim.platform.workzone.domain.ports.repositories.roles;
import uim.platform.workzone.application.dto;

class ManageRolesUseCase : UIMUseCase {
  private RoleRepository repo;

  this(RoleRepository repo) {
    this.repo = repo;
  }

  CommandResult createRole(CreateRoleRequest req) {
    if (req.name.length == 0)
      return CommandResult("", "Role name is required");

    auto now = Clock.currStdTime();
    auto r = Role();
    r.id = randomUUID().toString();
    r.tenantId = req.tenantId;
    r.name = req.name;
    r.description = req.description;
    r.permissions = req.permissions;
    r.isDefault = req.isDefault;
    r.createdAt = now;
    r.updatedAt = now;

    repo.save(r);
    return CommandResult(r.id, "");
  }

  Role* getRole(RoleId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  Role[] listRoles(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateRole(UpdateRoleRequest req) {
    auto r = repo.findById(req.id, req.tenantId);
    if (r is null)
      return CommandResult("", "Role not found");

    if (req.name.length > 0)
      r.name = req.name;
    if (req.description.length > 0)
      r.description = req.description;
    r.permissions = req.permissions;
    r.updatedAt = Clock.currStdTime();

    repo.update(*r);
    return CommandResult(r.id, "");
  }

  CommandResult deleteRole(RoleId id, TenantId tenantId) {
    auto r = repo.findById(id, tenantId);
    if (r is null)
      return CommandResult("", "Role not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
