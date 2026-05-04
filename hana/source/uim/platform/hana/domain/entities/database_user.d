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

  Json toJson() const {
    return Json.emptyObject
      .set("type", type.toString())
      .set("name", name)
      .set("schemaName", schemaName)
      .set("grantable", grantable);
  }
}

struct UserRole {
  string name;
  bool isDefault;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("isDefault", isDefault);
  }
}

struct DatabaseUser {
  mixin TenantEntity!(DatabaseUserId);

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

  Json toJson() const {
    return entityToJson
      .set("instanceId", instanceId.value)
      .set("userName", userName)
      .set("authType", authType.toString())
      .set("status", status.toString())
      .set("roles", roles.map!(r => r.toJson).array)
      .set("privileges", privileges.map!(p => p.toJson).array)
      .set("defaultSchema", defaultSchema)
      .set("isRestricted", isRestricted)
      .set("forcePasswordChange", forcePasswordChange)
      .set("failedLoginAttempts", failedLoginAttempts)
      .set("passwordExpiresAt", passwordExpiresAt)
      .set("lastLoginAt", lastLoginAt);
  }
}
