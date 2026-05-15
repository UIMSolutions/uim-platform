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
// import std.algorithm : canFind, filter;
 
// import uim.platform.portal.domain.types;
// import uim.platform.portal.application.dto;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageRolesUseCase { // TODO: UIMUseCase {
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
    role.initEntity(req.tenantId);
    with (role) {
      name = req.name;
      description = req.description;
      scope_ = req.scope_;
      userIds = null; // initially no users assigned
      groupIds = null; // initially no groups assigned
    }
    roleRepo.save(role);
    return RoleResponse(role.roleId, "");
  }

  Role getRole(RoleId id) {
    return roleRepo.findById(tenantId, id);
  }

  Role[] listRoles(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return roleRepo.findByTenant(tenantId, offset, limit);
  }

  CommandResult updateRole(UpdateRoleRequest req) {
    Role role = roleRepo.findById(req.roleId);
    if (role.isNull)
      return CommandResult(false, "", "Role not found");

    with (role) {
      name = req.name.length > 0 ? req.name : name;
      description = req.description;
      updatedAt = currentTimestamp();
    }
    roleRepo.update(role);
    return CommandResult(true, req.roleId.value, "");
  }

  CommandResult assignRole(AssignRoleRequest req) {
    Role role = roleRepo.findById(req.roleId);
    if (role.isNull)
      return CommandResult(false, "", "Role not found");

    with (role) {
      foreach (uid; req.userIds) {
        if (userIds.isNull)
          userIds = [];
        if (!userIds.canFind(uid))
          userIds ~= uid;

        foreach (gid; req.groupIds) {
          if (groupIds.isNull)
            groupIds = null;
          if (!groupIds.canFind(gid))
            groupIds ~= gid;
        }
        role.updatedAt = currentTimestamp();
      }
    }

    roleRepo.update(role);
    return CommandResult(true, req.roleId.value, "");
  }

  CommandResult unassignUsers(RoleId roleId, string[] unassignUserIds) {
    auto role = roleRepo.findById(roleId);
    if (role.isNull)
      return CommandResult(false, "", "Role not found");

    with (role) {
      userIds = userIds.filter!(u => !unassignUserIds.canFind(u)).array.toJson;
      updatedAt = currentTimestamp();
    }
    roleRepo.update(role);
    return CommandResult(true, roleId.value, "");
  }

  CommandResult deleteRole(RoleId id) {
    auto role = roleRepo.findById(id);
    if (role.isNull)
      return CommandResult(false, "", "Role not found");

    roleRepo.remove(role);
    return CommandResult(true, id.value, "");
  }
}
