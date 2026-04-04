/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage_roles;

import uim.platform.portal.domain.entities.role;
import uim.platform.portal.domain.types;
import uim.platform.portal.domain.ports.repositories.roles;
import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : canFind, filter;
// import std.array : array;

class ManageRolesUseCase : UIMUseCase {
  private RoleRepository roleRepo;

  this(RoleRepository roleRepo) {
    this.roleRepo = roleRepo;
  }

  RoleResponse createRole(CreateRoleRequest req) {
    if (req.name.length == 0)
      return RoleResponse("", "Role name is required");

    auto existing = roleRepo.findByName(req.tenantId, req.name);
    if (existing != Role.init)
      return RoleResponse("", "Role with this name already exists");

    auto now = Clock.currStdTime();
    auto id = randomUUID().toString();
    auto role = Role(id, req.tenantId, req.name, req.description, req.scope_, [], // userIds
      [], // groupIds
      now, now,);
    roleRepo.save(role);
    return RoleResponse(id, "");
  }

  Role getRole(RoleId id) {
    return roleRepo.findById(id);
  }

  Role[] listRoles(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return roleRepo.findByTenant(tenantId, offset, limit);
  }

  string updateRole(UpdateRoleRequest req) {
    auto role = roleRepo.findById(req.roleId);
    if (role == Role.init)
      return "Role not found";

    role.name = req.name.length > 0 ? req.name : role.name;
    role.description = req.description;
    role.updatedAt = Clock.currStdTime();
    roleRepo.update(role);
    return "";
  }

  string assignRole(AssignRoleRequest req) {
    auto role = roleRepo.findById(req.roleId);
    if (role == Role.init)
      return "Role not found";

    foreach (uid; req.userIds) {
      if (!role.userIds.canFind(uid))
        role.userIds ~= uid;
    }
    foreach (gid; req.groupIds) {
      if (!role.groupIds.canFind(gid))
        role.groupIds ~= gid;
    }
    role.updatedAt = Clock.currStdTime();
    roleRepo.update(role);
    return "";
  }

  string unassignUsers(RoleId roleId, string[] userIds) {
    auto role = roleRepo.findById(roleId);
    if (role == Role.init)
      return "Role not found";

    role.userIds = role.userIds.filter!(u => !userIds.canFind(u)).array;
    role.updatedAt = Clock.currStdTime();
    roleRepo.update(role);
    return "";
  }

  string deleteRole(RoleId id) {
    auto role = roleRepo.findById(id);
    if (role == Role.init)
      return "Role not found";

    roleRepo.remove(id);
    return "";
  }
}
