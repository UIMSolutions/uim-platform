/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.user;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// User in the identity directory.
struct IAUser {
  mixin TenantEntity!UserId;

  string userName;
  string email;
  string firstName;
  string lastName;
  /// Password hash (PBKDF2) — never serialized to clients.
  string passwordHash;
  UserStatus status = UserStatus.active;
  MfaType mfaType = MfaType.none;
  /// MFA secret (base32 TOTP seed) — never serialized to clients.
  string mfaSecret;
  GroupId[] groupIds;
  string phoneNumber;
  string externalIdpId;
  /// Identifier across the landscape (like the SAP Global User ID).
  UserId globalUserId;
  /// Consecutive failed logins since the last successful one.
  int failedLoginAttempts;
  long lastLoginAt;
  long passwordChangedAt;

  string displayName() const {
    auto name = (firstName ~ " " ~ lastName).strip;
    return name.length > 0 ? name : userName;
  }

  bool isActive() const {
    return status == UserStatus.active;
  }

  bool hasMfa() const {
    return mfaType != MfaType.none && mfaSecret.length > 0;
  }

  bool isMemberOf(GroupId groupId) const {
    return groupIds.canFind(groupId);
  }

  /// Client representation (without password hash and MFA secret).
  Json toJson() const {
    return entityToJson
      .set("userName", userName)
      .set("email", email)
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("displayName", displayName)
      .set("status", enumValue(status))
      .set("mfaType", enumValue(mfaType))
      .set("groupIds", groupIds.map!(id => Json(id.value)).array.toJson)
      .set("phoneNumber", phoneNumber)
      .set("externalIdpId", externalIdpId)
      .set("globalUserId", globalUserId.value)
      .set("failedLoginAttempts", failedLoginAttempts)
      .set("lastLoginAt", lastLoginAt)
      .set("passwordChangedAt", passwordChangedAt);
  }
}
///
unittest {
  mixin(ShowTest!("IAUser"));

  auto u = IAUser(TenantId("t1"));
  u.userName = "jdoe";
  u.passwordHash = "secret-hash";
  u.mfaSecret = "SEED";
  assert(u.displayName == "jdoe");
  u.firstName = "Jane";
  u.lastName = "Doe";
  assert(u.displayName == "Jane Doe");
  assert(!u.hasMfa);
  u.mfaType = MfaType.totp;
  assert(u.hasMfa);

  auto j = u.toJson;
  assert("passwordHash" !in j && "mfaSecret" !in j);
  assert(j["status"].get!string == "active");
}
