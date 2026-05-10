/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.roles;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class ManageRolesUseCase {
  private RoleRepository repo;

  this(RoleRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateRoleRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Role name is required");
    if (repo.existsByName(r.name, r.appId))
      return CommandResult(false, "", "A role with this name already exists for the application");

    import std.uuid : randomUUID;
    RoleEntity role;
    role.id              = randomUUID().toString();
    role.name            = r.name;
    role.description     = r.description;
    role.scopeReferences = r.scopeReferences.dup;
    role.appId           = r.appId;
    role.createdAt       = currentTimestamp();
    role.updatedAt       = role.createdAt;

    repo.save(role);
    return CommandResult(true, role.id, "");
  }

  CommandResult update(UpdateRoleRequest r) {
    auto role = repo.findById(r.id);
    if (role.id.length == 0)
      return CommandResult(false, "", "Role not found");

    if (r.description.length > 0)     role.description = r.description;
    if (r.scopeReferences.length > 0) role.scopeReferences = r.scopeReferences.dup;
    role.updatedAt = currentTimestamp();

    repo.update(role);
    return CommandResult(true, role.id, "");
  }

  CommandResult remove(RoleId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Role not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  RoleEntity getById(RoleId id) {
    return repo.findById(id);
  }

  RoleEntity[] listAll() {
    return repo.findAll();
  }
}
