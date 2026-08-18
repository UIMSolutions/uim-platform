/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.usecases.roles;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class ManageRolesUseCase {
  protected IRoleRepository repo;

  this(IRoleRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createRole(CreateRoleRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "Role name is required");
    if (repo.existsByName(r.tenantId, r.name, r.appId))
      return UsecaseResult(false, "", "A role with this name already exists for the application");

    auto role = RoleEntity(r.tenantId);
    role.name            = r.name;
    role.description     = r.description;
    role.scopeReferences = r.scopeReferences.dup;
    role.appId           = r.appId;

    repo.save(role);
    return UsecaseResult(true, role.id.value, "");
  }

  UsecaseResult updateRole(UpdateRoleRequest r) {
    auto role = repo.findById(r.tenantId, r.roleId);
    if (role.isNull )
      return UsecaseResult(false, "", "Role not found");

    if (r.description.length > 0)     role.description = r.description;
    if (r.scopeReferences.length > 0) role.scopeReferences = r.scopeReferences.dup;
    role.updatedAt = currentTimestamp();

    repo.update(role);
    return UsecaseResult(true, role.id.value, "");
  }

  UsecaseResult deleteRole(TenantId tenantId, RoleId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Role not found");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }

  RoleEntity getRole(TenantId tenantId, RoleId id) {
    return repo.findById(tenantId, id);
  }

  RoleEntity[] listRoles(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }
}

///
unittest {
//     auto repo = new RoleRepository();
//     auto usecase = new ManageRolesUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test list
//     auto items = usecase.listRoles(tenantId);
//     assert(items !is null);

}
