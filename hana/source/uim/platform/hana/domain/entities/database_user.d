/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.entities.database_user;

// import uim.platform.hana.domain.types;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct UserPrivilege {
  PrivilegeType type;
  string name;
  string schemaName;
  bool grantable;
}

struct UserRole {
  string name;
  bool isDefault;
}

struct DatabaseUser {
  DatabaseUserId id;
  TenantId tenantId;
  InstanceId instanceId;
  string userName;
  AuthType authType;
  UserStatus status;
  UserRole[] roles;
  UserPrivilege[] privileges;
  string defaultSchema;
  bool isRestricted;
  bool forcePasswordChange;
  int failedLoginAttempts;
  long passwordExpiresAt;
  long lastLoginAt;
  long createdAt;
  long updatedAt;
}
