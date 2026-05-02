/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.business_users;

// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.business_user;
// import uim.platform.abap_environment.domain.ports.repositories.business_users;
// import uim.platform.abap_environment.domain.ports.repositories.business_roles;
// import uim.platform.abap_environment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Application service for business user management.
class ManageBusinessUsersUseCase { // TODO: UIMUseCase {
  private BusinessUserRepository repo;
  private BusinessRoleRepository roleRepo;

  this(BusinessUserRepository repo, BusinessRoleRepository roleRepo) {
    this.repo = repo;
    this.roleRepo = roleRepo;
  }

  CommandResult createUser(CreateBusinessUserRequest req) {
    if (req.username.length == 0)
      return CommandResult(false, "", "Username is required");
    if (req.email.length == 0)
      return CommandResult(false, "", "Email is required");
    if (req.systemInstanceId.isEmpty)
      return CommandResult(false, "", "System instance ID is required");

    auto existing = repo.findByUsername(req.systemInstanceId, req.username);
    if (!existing.isNull)
      return CommandResult(false, "", "Username '" ~ req.username ~ "' already exists");

    auto emailCheck = repo.findByEmail(req.systemInstanceId, req.email);
    if (!emailCheck.isNull)
      return CommandResult(false, "", "Email '" ~ req.email ~ "' already in use");

    BusinessUser user;
    user.id = randomUUID();
    user.tenantId = req.tenantId;
    user.systemInstanceId = req.systemInstanceId;
    user.username = req.username;
    user.firstName = req.firstName;
    user.lastName = req.lastName;
    user.email = req.email;
    user.status = UserStatus.active;
    user.passwordChangeRequired = true;

    // Assign roles
    foreach (roleId; req.roleIds) {
      auto roleIdObj = BusinessRoleId(roleId);
      if (roleRepo.existsById(roleIdObj)) {
        auto role = roleRepo.findById(roleIdObj);
        // import std.datetime.systime : Clock;
        user.roleAssignments ~= RoleAssignment(roleIdObj, role.name, Clock.currStdTime());
      }
    }

    // import std.datetime.systime : Clock;
    user.createdAt = Clock.currStdTime();
    user.updatedAt = user.createdAt;

    repo.save(user);
    return CommandResult(true, user.id.value, "");
  }

  CommandResult updateUser(BusinessUserId id, UpdateBusinessUserRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Business user not found");

    auto user = repo.findById(id);
    if (req.firstName.length > 0)
      user.firstName = req.firstName;
    if (req.lastName.length > 0)
      user.lastName = req.lastName;
    if (req.email.length > 0)
      user.email = req.email;
    if (req.status.length > 0)
      user.status = req.status.to!UserStatus;

    // Re-assign roles if provided
    if (req.roleIds.length > 0) {
      RoleAssignment[] assignments;
      foreach (roleId; req.roleIds) {
        auto roleIdObj = BusinessRoleId(roleId);
        if (roleRepo.existsById(roleIdObj)) {
          auto role = roleRepo.findById(roleIdObj);
          assignments ~= RoleAssignment(roleIdObj, role.name, Clock.currStdTime());
        }
      }
      user.roleAssignments = assignments;
    }

    // import std.datetime.systime : Clock;
    user.updatedAt = Clock.currStdTime();

    repo.update(user);
    return CommandResult(true, id.value, "");
  }

  BusinessUser* getUser(BusinessUserId id) {
    return repo.findById(id);
  }

  BusinessUser[] listUsers(SystemInstanceId systemId) {
    return repo.findBySystem(systemId);
  }

  CommandResult deleteUser(BusinessUserId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Business user not found");

    repo.removeById(id);
    return CommandResult(true, id.value(), "");
  }
}
