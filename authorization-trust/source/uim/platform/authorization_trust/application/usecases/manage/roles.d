/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.roles;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class ManageRolesUseCase {
  private RoleRepository repo;

  this(RoleRepository repo) {
    this.repo = repo;
  }

  CommandResult createRole(CreateRoleRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Role name is required");
    if (repo.existsByName(r.tenantId, r.name, r.appId))
      return CommandResult(false, "", "A role with this name already exists for the application");

    auto role = RoleEntity(r.tenantId);
    role.name            = r.name;
    role.description     = r.description;
    role.scopeReferences = r.scopeReferences.dup;
    role.appId           = r.appId;

    repo.save(role);
    return CommandResult(true, role.id.value, "");
  }

  CommandResult updateRole(UpdateRoleRequest r) {
    auto role = repo.find(r.tenantId, r.roleId);
    if (role.isNull )
      return CommandResult(false, "", "Role not found");

    if (r.description.length > 0)     role.description = r.description;
    if (r.scopeReferences.length > 0) role.scopeReferences = r.scopeReferences.dup;
    role.updatedAt = currentTimestamp();

    repo.update(role);
    return CommandResult(true, role.id.value, "");
  }

  CommandResult deleteRole(TenantId tenantId, RoleId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Role not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }

  RoleEntity getRole(TenantId tenantId, RoleId id) {
    return repo.findById(tenantId, id);
  }

  RoleEntity[] listRoles(TenantId tenantId) {
    return repo.find(tenantId);
  }
}
