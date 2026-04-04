/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.application.usecases.manage.business_users;

import uim.platform.abap_enviroment.application.dto;
import uim.platform.abap_enviroment.domain.entities.business_user;
import uim.platform.abap_enviroment.domain.ports.repositories.business_users;
import uim.platform.abap_enviroment.domain.ports.repositories.business_roles;
import uim.platform.abap_enviroment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;

/// Application service for business user management.
class ManageBusinessUsersUseCase : UIMUseCase {
  private BusinessUserRepository repo;
  private BusinessRoleRepository roleRepo;

  this(BusinessUserRepository repo, BusinessRoleRepository roleRepo) {
    this.repo = repo;
    this.roleRepo = roleRepo;
  }

  CommandResult createUser(CreateBusinessUserRequest req) {
    if (req.username.length == 0)
      return CommandResult("", "Username is required");
    if (req.email.length == 0)
      return CommandResult("", "Email is required");
    if (req.systemInstanceId.length == 0)
      return CommandResult("", "System instance ID is required");

    auto existing = repo.findByUsername(req.systemInstanceId, req.username);
    if (existing !is null)
      return CommandResult("", "Username '" ~ req.username ~ "' already exists");

    auto emailCheck = repo.findByEmail(req.systemInstanceId, req.email);
    if (emailCheck !is null)
      return CommandResult("", "Email '" ~ req.email ~ "' already in use");

    auto id = randomUUID().toString();
    BusinessUser user;
    user.id = id;
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
      auto role = roleRepo.findById(roleId);
      if (role !is null) {
        // import std.datetime.systime : Clock;
        user.roleAssignments ~= RoleAssignment(roleId, role.name, Clock.currStdTime());
      }
    }

    // import std.datetime.systime : Clock;
    user.createdAt = Clock.currStdTime();
    user.updatedAt = user.createdAt;

    repo.save(user);
    return CommandResult(id, "");
  }

  CommandResult updateUser(BusinessUserId id, UpdateBusinessUserRequest req) {
    auto user = repo.findById(id);
    if (user is null)
      return CommandResult("", "Business user not found");

    if (req.firstName.length > 0)
      user.firstName = req.firstName;
    if (req.lastName.length > 0)
      user.lastName = req.lastName;
    if (req.email.length > 0)
      user.email = req.email;
    if (req.status.length > 0)
      user.status = parseUserStatus(req.status);

    // Re-assign roles if provided
    if (req.roleIds.length > 0) {
      RoleAssignment[] assignments;
      foreach (roleId; req.roleIds) {
        auto role = roleRepo.findById(roleId);
        if (role !is null) {
          // import std.datetime.systime : Clock;
          assignments ~= RoleAssignment(roleId, role.name, Clock.currStdTime());
        }
      }
      user.roleAssignments = assignments;
    }

    // import std.datetime.systime : Clock;
    user.updatedAt = Clock.currStdTime();

    repo.update(*user);
    return CommandResult(id, "");
  }

  BusinessUser* getUser(BusinessUserId id) {
    return repo.findById(id);
  }

  BusinessUser[] listUsers(SystemInstanceId systemId) {
    return repo.findBySystem(systemId);
  }

  CommandResult deleteUser(BusinessUserId id) {
    auto user = repo.findById(id);
    if (user is null)
      return CommandResult("", "Business user not found");

    repo.remove(id);
    return CommandResult(id, "");
  }
}

private UserStatus parseUserStatus(string s) {
  switch (s) {
  case "active":
    return UserStatus.active;
  case "inactive":
    return UserStatus.inactive;
  case "locked":
    return UserStatus.locked;
  case "passwordLocked":
    return UserStatus.passwordLocked;
  default:
    return UserStatus.active;
  }
}
