/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.user;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Core user entity in the identity directory.
struct User {
  UserId id;
  TenantId tenantId;
  string userName;
  string email;
  string firstName;
  string lastName;
  string passwordHash;
  UserStatus status = UserStatus.active;
  MfaType mfaType = MfaType.none;
  string mfaSecret;
  string[] groupIds;
  string phoneNumber;
  string externalIdpId;
  long createdAt;
  long updatedAt;
  string globalUserId; // Unique identifier across landscape (like SAP Global User ID)

  string displayName() const
  {
    return firstName ~ " " ~ lastName;
  }

  bool isActive() const
  {
    return status == UserStatus.active;
  }

  bool hasMfa() const
  {
    return mfaType != MfaType.none;
  }

  Json toJson() {
    return Json.emptyObject.set("id", id.value).set("tenantId", tenantId)
      .set("userName", userName).set("email", email).set("firstName",
        firstName).set("lastName", lastName) // Note: Exclude passwordHash and mfaSecret from JSON for security reasons
      .set("status", to!string(status))
      .set("mfaType", to!string(mfaType)).set("groupIds", groupIds).set("phoneNumber", phoneNumber)
      .set("externalIdpId", externalIdpId).set("createdAt", createdAt)
      .set("updatedAt", updatedAt).set("globalUserId", globalUserId);
  }
}
