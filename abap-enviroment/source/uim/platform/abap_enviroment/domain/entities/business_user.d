module uim.platform.abap_enviroment.domain.entities.business_user;

import uim.platform.abap_enviroment.domain.types;

/// Business role assignment carried by a user.
struct RoleAssignment
{
  BusinessRoleId roleId;
  string roleName;
  long assignedAt;
}

/// Business user in the ABAP environment.
struct BusinessUser
{
  BusinessUserId id;
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  string username;
  string firstName;
  string lastName;
  string email;
  UserStatus status = UserStatus.active;

  /// Role assignments
  RoleAssignment[] roleAssignments;

  /// Authentication
  bool passwordChangeRequired;
  long lastLoginAt;
  int failedLoginAttempts;

  /// Metadata
  string createdBy;
  long createdAt;
  long updatedAt;
}
