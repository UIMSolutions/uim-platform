/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.roles;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.role;
// import uim.platform.workzone.domain.ports.repositories.roles;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageRolesUseCase { // TODO: UIMUseCase {
  private RoleRepository repo;

  this(RoleRepository repo) {
    this.repo = repo;
  }

  CommandResult createRole(CreateRoleRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Role name is required");

    auto now = currentTimestamp();
    Role r;
    r.initEntity(req.tenantId);

    r.name = req.name;
    r.description = req.description;
    r.permissions = req.permissions;
    r.isDefault = req.isDefault;
    
    repo.save(r);
    return CommandResult(true, r.id.value, "");
  }

  Role getRole(TenantId tenantId, RoleId id) {
    return repo.findById(tenantId, id);
  }

  Role[] listRoles(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateRole(UpdateRoleRequest req) {
    auto r = repo.findById(req.tenantId, req.id);
    if (r.isNull)
      return CommandResult(false, "", "Role not found");

    if (req.name.length > 0)
      r.name = req.name;
    if (req.description.length > 0)
      r.description = req.description;
    r.permissions = req.permissions;
    r.updatedAt = currentTimestamp();

    repo.update(r);
    return CommandResult(true, r.id.value, "");
  }

  CommandResult deleteRole(TenantId tenantId, RoleId id) {
    auto r = repo.findById(tenantId, id);
    if (r.isNull)
      return CommandResult(false, "", "Role not found");

    repo.remove(r);
    return CommandResult(true, r.id.value, "");
  }
}
