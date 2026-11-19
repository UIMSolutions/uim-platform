/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.ports.usecases.users;
// import uim.platform.identity_directory.domain.entities.user;

// import uim.platform.identity_directory.domain.ports.repositories.users;
// import uim.platform.identity_directory.domain.ports.repositories.password_service;
// import uim.platform.identity_directory.domain.ports.repositories.password_policys;
// import uim.platform.identity_directory.domain.services.password_validator;



import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Application use case: SCIM 2.0 user management (CRUD + search).
interface IManageUsersUseCase {

  /// Create a new user.
  UsecaseResult createUser(CreateUserRequest req);

  /// Get user by ID.
  IDUser getUser(TenantId tenantId, UserId id);

  /// List users for a tenant (SCIM paginated).
  IDUser[] listUsers(TenantId tenantId);

  /// Search users with a SCIM-like filter.
  IDUser[] searchUsers(TenantId tenantId, string filter);

  /// Update user profile.
  UsecaseResult updateUser(UpdateUserRequest req);

  /// Deactivate (soft-delete) a user.
  UsecaseResult deactivateUser(TenantId tenantId, UserId id);

  /// Delete a user permanently.
  UsecaseResult deleteUser(TenantId tenantId, UserId id);

  /// Change user password.
  UsecaseResult changePassword(TenantId tenantId, UserId id, string oldPassword, string newPassword);

}
