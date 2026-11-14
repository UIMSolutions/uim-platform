/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.mappers.user;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// IAUser ⇄ snapshot record (includes the password hash and MFA secret —
/// protect the data directory accordingly).
struct UserMapper {
  static Json toRecord(const IAUser e) {
    auto r = baseRecord(e);
    r["userName"] = e.userName;
    r["email"] = e.email;
    r["firstName"] = e.firstName;
    r["lastName"] = e.lastName;
    r["passwordHash"] = e.passwordHash;
    r["status"] = enumValue(e.status);
    r["mfaType"] = enumValue(e.mfaType);
    r["mfaSecret"] = e.mfaSecret;
    r["groupIds"] = idsRecord(e.groupIds);
    r["phoneNumber"] = e.phoneNumber;
    r["externalIdpId"] = e.externalIdpId;
    r["globalUserId"] = e.globalUserId.value;
    r["failedLoginAttempts"] = e.failedLoginAttempts;
    r["lastLoginAt"] = e.lastLoginAt;
    r["passwordChangedAt"] = e.passwordChangedAt;
    return r;
  }

  static IAUser fromRecord(Json r) {
    IAUser e;
    readBase(e, r);
    e.userName = fieldString(r, "userName");
    e.email = fieldString(r, "email");
    e.firstName = fieldString(r, "firstName");
    e.lastName = fieldString(r, "lastName");
    e.passwordHash = fieldString(r, "passwordHash");
    e.status = fieldEnum!UserStatus(r, "status", UserStatus.active);
    e.mfaType = fieldEnum!MfaType(r, "mfaType", MfaType.none);
    e.mfaSecret = fieldString(r, "mfaSecret");
    e.groupIds = fieldIds!GroupId(r, "groupIds");
    e.phoneNumber = fieldString(r, "phoneNumber");
    e.externalIdpId = fieldString(r, "externalIdpId");
    e.globalUserId = UserId(fieldString(r, "globalUserId"));
    e.failedLoginAttempts = cast(int) fieldLong(r, "failedLoginAttempts");
    e.lastLoginAt = fieldLong(r, "lastLoginAt");
    e.passwordChangedAt = fieldLong(r, "passwordChangedAt");
    return e;
  }
}
///
unittest {
  mixin(ShowTest!("UserMapper"));

  auto u = IAUser(TenantId("t1"), UserId("u1"), UserId("admin"));
  u.email = "jane@example.com";
  u.passwordHash = "pbkdf2-sha256$1$a$b";
  u.status = UserStatus.pendingVerification;
  u.mfaType = MfaType.totp;
  u.mfaSecret = "JBSWY3DP";
  u.groupIds = [GroupId("g1"), GroupId("g2")];
  u.failedLoginAttempts = 2;
  auto back = UserMapper.fromRecord(UserMapper.toRecord(u));
  assert(back.id == u.id && back.tenantId == u.tenantId && back.createdBy == u.createdBy);
  assert(back.passwordHash == u.passwordHash && back.mfaSecret == u.mfaSecret);
  assert(back.status == UserStatus.pendingVerification && back.mfaType == MfaType.totp);
  assert(back.groupIds == u.groupIds && back.failedLoginAttempts == 2);
}
