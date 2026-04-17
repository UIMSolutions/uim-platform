/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.roles;

// import uim.platform.portal.domain.entities.role;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.roles;
// import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : canFind, filter;
// import std.array : array;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.application.dto;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageRolesUseCase : UIMUseCase {
  private RoleRepository roleRepo;

  this(RoleRepository roleRepo) {
    this.roleRepo = roleRepo;
  }

  RoleResponse createRole(CreateRoleRequest req) {
    if (req.name.length == 0)
      return RoleResponse("", "Role name is required");

    if (roleRepo.existsByName(req.tenantId, req.name))
      return RoleResponse(RoleId(""), "Role with this name already exists");

    auto existing = roleRepo.findByName(req.tenantId, req.name);
    Role role;
    with (role) {
      roleId = randomUUID();
      tenantId = req.tenantId;
      name = req.name;
      description = req.description;
      scope_ = req.scope_;
      userIds = null; // initially no users assigned
      groupIds = null; // initially no groups assigned
      createdAt = Clock.currStdTime();
      updatedAt = createdAt;
    }
    roleRepo.save(role);
    return RoleResponse(role.roleId, "");
  }

  Role getRole(RoleId id) {
    return roleRepo.findById(id);
  }

  Role[] listRoles(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return roleRepo.findByTenant(tenantId, offset, limit);
  }

  string updateRole(UpdateRoleRequest req) {
    if (!roleRepo.existsById(req.roleId))
      return "Role not found";

    auto role = roleRepo.findById(req.roleId);
    role.name = req.name.length > 0 ? req.name : role.name;
    role.description = req.description;
    role.updatedAt = Clock.currStdTime();
    roleRepo.update(role);
    return "";
  }

  string assignRole(AssignRoleRequest req) {
    if (!roleRepo.existsById(req.roleId))
      return "Role not found";

    auto role = roleRepo.findById(req.roleId);
    foreach (uid; req.userIds) {
      if (role.userIds is null)
        role.userIds = [];
      if (!role.userIds.canFind(uid))
        role.userIds ~= uid;
    }
    foreach (gid; req.groupIds) {
      if (role.groupIds is null)
        role.groupIds = null;
      if (!role.groupIds.canFind(gid))
        role.groupIds ~= gid;
    }
    role.updatedAt = Clock.currStdTime();
    roleRepo.update(role);
    return "";
  }

  string unassignUsers(RoleId roleId, string[] userIds) {
    if (!roleRepo.existsById(roleId))
      return "Role not found";

    auto role = roleRepo.findById(roleId);
    role.userIds = role.userIds.filter!(u => !userIds.canFind(u)).array;
    role.updatedAt = Clock.currStdTime();
    roleRepo.update(role);
    return "";
  }

  string deleteRole(RoleId id) {
    if (!roleRepo.existsById(id))
      return "Role not found";

    roleRepo.remove(id);
    return "";
  }
}
