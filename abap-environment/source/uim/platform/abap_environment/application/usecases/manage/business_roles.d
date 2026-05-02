/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.business_roles;

// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.business_role;
// import uim.platform.abap_environment.domain.ports.repositories.business_roles;
// import uim.platform.abap_environment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Application service for business role management.
class ManageBusinessRolesUseCase { // TODO: UIMUseCase {
  private BusinessRoleRepository repo;

  this(BusinessRoleRepository repo) {
    this.repo = repo;
  }

  CommandResult createRole(CreateBusinessRoleRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Role name is required");

    if (req.systemInstanceId.isEmpty())
      return CommandResult(false, "", "System instance ID is required");

    auto existing = repo.findByName(req.systemInstanceId, req.name);
    if (existing !is null)
      return CommandResult(false, "", "Business role '" ~ req.name ~ "' already exists");

    BusinessRole role;
    role.id = randomUUID();
    role.tenantId = req.tenantId;
    role.systemInstanceId = req.systemInstanceId;
    role.name = req.name;
    role.description = req.description;
    role.roleType = req.roleType.to!RoleType;
    role.restrictionTypes = req.restrictionTypes;
    role.assignedCatalogs = req.assignedCatalogs;

    // import std.datetime.systime : Clock;
    role.createdAt = Clock.currStdTime();
    role.updatedAt = role.createdAt;

    repo.save(role);
    return CommandResult(true, id.value, "");
  }

  CommandResult updateRole(BusinessRoleId id, UpdateBusinessRoleRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Business role not found");

    auto role = repo.findById(id);
    if (req.description.length > 0)
      role.description = req.description;
    if (req.roleType.length > 0)
      role.roleType = req.roleType.to!RoleType;
    if (req.restrictionTypes.length > 0)
      role.restrictionTypes = req.restrictionTypes;
    if (req.assignedCatalogs.length > 0)
      role.assignedCatalogs = req.assignedCatalogs;

    // import std.datetime.systime : Clock;
    role.updatedAt = Clock.currStdTime();

    repo.update(*role);
    return CommandResult(true, id.value, "");
  }

  BusinessRole getRole(BusinessRoleId id) {
    return repo.findById(id);
  }

  BusinessRole[] listRoles(SystemInstanceId systemId) {
    return repo.findBySystem(systemId);
  }

  CommandResult deleteRole(BusinessRoleId roleId) {
    if (!repo.existsById(roleId))
      return CommandResult(false, "", "Business role not found");

    repo.remove(roleId);
    return CommandResult(true, roleid.value(), "");
  }
}
