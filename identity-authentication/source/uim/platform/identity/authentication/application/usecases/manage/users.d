/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.application.usecases.manage.users;
// import uim.platform.identity.authentication.domain.entities.user;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.user;
// import uim.platform.identity.authentication.domain.ports.repositories.password_service;
// import uim.platform.identity.authentication.application.dto;
// 
// 
// 

import uim.platform.identity.authentication;

mixin(ShowModule!());
@safe:
/// Application use case: SCIM-like user management (CRUD).
class ManageUsersUseCase { // TODO: UIMUseCase {
  private UserRepository userRepo;
  private PasswordService passwordSvc;

  this(UserRepository userRepo, PasswordService passwordSvc) {
    this.userRepo = userRepo;
    this.passwordSvc = passwordSvc;
  }

  /// Create a new user.
  UserResponse createUser(CreateUserRequest req) {
    // Check uniqueness
    if (userRepo.existsByEmail(req.tenantId, req.email))
      return UserResponse("", "User with this email already exists");

    auto now = currentTimestamp();
    auto user = User(req.tenantId);
    user.userName = req.userName;
    user.email = req.email;
    user.firstName = req.firstName;
    user.lastName = req.lastName;
    user.passwordHash = passwordSvc.hashPassword(req.password);
    user.status = UserStatus.active;
    user.mfaType = MfaType.none;
    user.phoneNumber = req.phoneNumber;
    user.createdAt = now;
    user.updatedAt = now;
    user.globalUserId = randomUUID().toString();

    userRepo.save(user);
    return UserResponse(user.id.value, "");
  }

  /// Get user by ID.
  User getUser(UserId id) {
    return userRepo.findById(tenantId, id);
  }

  /// List users for a tenant.
  User[] listUsers(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return userRepo.findByTenant(tenantId, offset, limit);
  }

  /// Update user profile.
  CommandResult updateUser(UpdateUserRequest req) {
    auto user = userRepo.findById(req.userId);
    if (user.isNull)
      return CommandResult(false, "", "User not found");

    if (req.firstName.length > 0)
      user.firstName = req.firstName;
    if (req.lastName.length > 0)
      user.lastName = req.lastName;
    if (req.phoneNumber.length > 0)
      user.phoneNumber = req.phoneNumber;

    user.updatedAt = currentTimestamp();
    userRepo.update(user);
    return CommandResult(true, user.id.value, "User updated successfully.");
  }

  /// Deactivate (soft-delete) a user.
  CommandResult deactivateUser(UserId id) {
    auto user = userRepo.findById(tenantId, id);
    if (user.isNull)
      return CommandResult(false, "", "User not found");

    user.status = UserStatus.inactive;
    user.updatedAt = currentTimestamp();
    userRepo.update(user);
    return CommandResult(true, user.id.value, "User deactivated successfully.");
  }

  /// Change password.
  CommandResult changePassword(UserId id, string oldPassword, string newPassword) {
    auto user = userRepo.findById(tenantId, id);
    if (user.isNull)
      return CommandResult(false, "", "User not found");

    if (!passwordSvc.verifyPassword(oldPassword, user.passwordHash))
      return CommandResult(false, "", "Current password is incorrect");

    user.passwordHash = passwordSvc.hashPassword(newPassword);
    user.updatedAt = currentTimestamp();
    userRepo.update(user);
    return CommandResult(true, user.id.value, "Password changed successfully.");
  }
}
