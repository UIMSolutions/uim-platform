/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.users;

// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.user;
// import uim.platform.identity_authentication.domain.ports.repositories.password_service;
// import uim.platform.identity_authentication.application.dto;
// 
// // import std.uuid;
// // import std.datetime.systime : Clock;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: SCIM-like user management (CRUD).
class ManageUsersUseCase : UIMUseCase {
  private UserRepository userRepo;
  private PasswordService passwordSvc;

  this(UserRepository userRepo, PasswordService passwordSvc) {
    this.userRepo = userRepo;
    this.passwordSvc = passwordSvc;
  }

  /// Create a new user.
  UserResponse createUser(CreateUserRequest req) {
    // Check uniqueness
    auto existing = userRepo.findByEmail(req.tenantId, req.email);
    if (existing != User.init)
      return UserResponse("", "User with this email already exists");

    auto now = Clock.currStdTime();
    auto user = User(randomUUID().toString(), req.tenantId, req.userName,
        req.email, req.firstName, req.lastName, passwordSvc.hashPassword(req.password),
        UserStatus.active, MfaType.none, "", [], req.phoneNumber, "", now, now,
        randomUUID().toString() // globalUserId

        );
    userRepo.save(user);
    return UserResponse(user.id, "");
  }

  /// Get user by ID.
  User getUser(UserId id) {
    return userRepo.findById(id);
  }

  /// List users for a tenant.
  User[] listUsers(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return userRepo.findByTenant(tenantId, offset, limit);
  }

  /// Update user profile.
  string updateUser(UpdateUserRequest req) {
    auto user = userRepo.findById(req.userId);
    if (user == User.init)
      return "User not found";

    if (req.firstName.length > 0)
      user.firstName = req.firstName;
    if (req.lastName.length > 0)
      user.lastName = req.lastName;
    if (req.phoneNumber.length > 0)
      user.phoneNumber = req.phoneNumber;

    user.updatedAt = Clock.currStdTime();
    userRepo.update(user);
    return "";
  }

  /// Deactivate (soft-delete) a user.
  string deactivateUser(UserId id) {
    auto user = userRepo.findById(id);
    if (user == User.init)
      return "User not found";

    user.status = UserStatus.inactive;
    user.updatedAt = Clock.currStdTime();
    userRepo.update(user);
    return "";
  }

  /// Change password.
  string changePassword(UserId id, string oldPassword, string newPassword) {
    auto user = userRepo.findById(id);
    if (user == User.init)
      return "User not found";

    if (!passwordSvc.verifyPassword(oldPassword, user.passwordHash))
      return "Current password is incorrect";

    user.passwordHash = passwordSvc.hashPassword(newPassword);
    user.updatedAt = Clock.currStdTime();
    userRepo.update(user);
    return "";
  }
}
