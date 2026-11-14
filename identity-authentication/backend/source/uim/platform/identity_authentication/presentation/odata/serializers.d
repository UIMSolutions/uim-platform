/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Conversion of domain entities to OData v4 JSON payloads.
/// Requests are read with presentation.payloads (shared with REST).
module uim.platform.identity_authentication.presentation.odata.serializers;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// stdTime (hnsecs) → Edm.DateTimeOffset ("2026-11-09T10:00:00Z"); 0 → null.
Json odataTime(long stdTime) @trusted {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime, UTC());
  t.fracSecs = Duration.zero;
  return Json(t.toISOExtString);
}

private void base(T)(ref Json j, const ref T e) {
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdBy"] = e.createdBy.value;
  j["createdAt"] = odataTime(e.createdAt);
  j["updatedBy"] = e.updatedBy.value;
  j["updatedAt"] = odataTime(e.updatedAt);
}

private string state(bool revoked, bool expired) {
  return revoked ? "revoked" : expired ? "expired" : "active";
}

Json toOData(const IAUser e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["userName"] = e.userName;
  j["email"] = e.email;
  j["firstName"] = e.firstName;
  j["lastName"] = e.lastName;
  j["displayName"] = e.displayName;
  j["status"] = enumValue(e.status);
  j["mfaType"] = enumValue(e.mfaType);
  j["phoneNumber"] = e.phoneNumber;
  j["externalIdpId"] = e.externalIdpId;
  j["globalUserId"] = e.globalUserId.value;
  j["groupCount"] = cast(int) e.groupIds.length;
  j["failedLoginAttempts"] = e.failedLoginAttempts;
  j["lastLoginAt"] = odataTime(e.lastLoginAt);
  j["passwordChangedAt"] = odataTime(e.passwordChangedAt);
  j["password"] = Json(null); // write-only
  return j;
}

Json toOData(const IAGroup e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["memberCount"] = cast(int) e.memberUserIds.length;
  j["memberUserIds"] = e.memberUserIds.map!(m => m.value).join(",");
  return j;
}

/// clientSecret is only filled right after create / rotate.
Json toOData(const Application e, string clientSecret = null) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["protocol"] = enumValue(e.protocol);
  j["clientId"] = e.clientId;
  j["clientSecret"] = clientSecret.length ? Json(clientSecret) : Json(null);
  j["redirectUris"] = e.redirectUris.join(" ");
  j["allowedScopes"] = e.allowedScopes.join(" ");
  j["samlEntityId"] = e.samlEntityId;
  j["samlAcsUrl"] = e.samlAcsUrl;
  j["samlMetadataUrl"] = e.samlMetadataUrl;
  j["active"] = e.active;
  return j;
}

Json toOData(const AuthorizationPolicy e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["rules"] = e.rules.map!(r => r.toText).join("; ");
  j["applicationIds"] = e.applicationIds.join(",");
  j["active"] = e.active;
  return j;
}

Json toOData(const RiskRule e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["conditions"] = e.conditions.map!(c => c.toText).join("; ");
  j["riskLevel"] = enumValue(e.riskLevel);
  j["requiredMfa"] = enumValue(e.requiredMfa);
  j["denyAccess"] = e.denyAccess;
  j["active"] = e.active;
  return j;
}

Json toOData(const IdpConfig e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["idpType"] = enumValue(e.idpType);
  j["metadataUrl"] = e.metadataUrl;
  j["authorizationEndpoint"] = e.authorizationEndpoint;
  j["tokenEndpoint"] = e.tokenEndpoint;
  j["userInfoEndpoint"] = e.userInfoEndpoint;
  j["clientId"] = e.clientId;
  j["clientSecret"] = Json(null); // write-only
  j["domainHints"] = e.domainHints.join(",");
  j["isDefault"] = e.isDefault;
  j["active"] = e.active;
  return j;
}

Json toOData(const IASession e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["userId"] = e.userId.value;
  j["applicationId"] = e.applicationId.value;
  j["authMethod"] = enumValue(e.authMethod);
  j["mfaUsed"] = enumValue(e.mfaUsed);
  j["ipAddress"] = e.ipAddress;
  j["userAgent"] = e.userAgent;
  j["riskLevel"] = enumValue(e.riskLevel);
  j["expiresAt"] = odataTime(e.expiresAt);
  j["revoked"] = e.revoked;
  j["state"] = state(e.revoked, e.isExpired(Clock.currStdTime()));
  return j;
}

Json toOData(const Token e) {
  auto j = Json.emptyObject;
  base(j, e);
  j["userId"] = e.userId.value;
  j["applicationId"] = e.applicationId.value;
  j["sessionId"] = e.sessionId.value;
  j["tokenType"] = enumValue(e.tokenType);
  j["scopes"] = e.scopes.join(" ");
  j["issuedAt"] = odataTime(e.issuedAt);
  j["expiresAt"] = odataTime(e.expiresAt);
  j["revoked"] = e.revoked;
  j["state"] = state(e.revoked, e.isExpired(Clock.currStdTime()));
  return j;
}

Json toOData(const IdentityStatistics s) {
  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId.value;
  j["users"] = cast(int) s.users;
  j["activeUsers"] = cast(int) s.activeUsers;
  j["lockedUsers"] = cast(int) s.lockedUsers;
  j["inactiveUsers"] = cast(int) s.inactiveUsers;
  j["pendingUsers"] = cast(int) s.pendingUsers;
  j["mfaUsers"] = cast(int) s.mfaUsers;
  j["mfaCoverage"] = s.mfaCoverage;
  j["usersWithFailedLogins"] = cast(int) s.usersWithFailedLogins;
  j["groups"] = cast(int) s.groups;
  j["applications"] = cast(int) s.applications;
  j["activeApplications"] = cast(int) s.activeApplications;
  j["policies"] = cast(int) s.policies;
  j["riskRules"] = cast(int) s.riskRules;
  j["identityProviders"] = cast(int) s.identityProviders;
  j["sessions"] = cast(int) s.sessions;
  j["activeSessions"] = cast(int) s.activeSessions;
  j["tokens"] = cast(int) s.tokens;
  j["activeTokens"] = cast(int) s.activeTokens;
  j["lastLoginAt"] = odataTime(s.lastLoginAt);
  return j;
}

///
unittest {
  mixin(ShowTest!("odata serializers"));

  auto model = identityODataModel();
  void conforms(string set, Json j) {
    foreach (key, value; j.get!(Json[string]))
      assert(model.find(set).hasProperty(key), set ~ "." ~ key);
    foreach (prop; model.find(set).properties)
      assert(prop.name in j, set ~ "." ~ prop.name);
  }

  auto u = IAUser(TenantId("t1"), UserId("u1"));
  u.passwordHash = "secret";
  u.mfaSecret = "seed";
  auto j = toOData(u);
  assert(j["id"].get!string == "u1" && j["password"].type == Json.Type.null_);
  assert(!j.toString.canFind("secret") && !j.toString.canFind("seed"));
  assert(j["lastLoginAt"].type == Json.Type.null_);

  conforms("Users", j);
  conforms("Groups", toOData(IAGroup(TenantId("t1"))));
  conforms("Applications", toOData(Application(TenantId("t1"))));
  conforms("Policies", toOData(AuthorizationPolicy(TenantId("t1"))));
  conforms("RiskRules", toOData(RiskRule(TenantId("t1"))));
  conforms("IdentityProviders", toOData(IdpConfig(TenantId("t1"))));
  conforms("Sessions", toOData(IASession(TenantId("t1"))));
  conforms("Tokens", toOData(Token(TenantId("t1"))));
  conforms("Statistics", toOData(IdentityStatistics.init));

  auto app = Application(TenantId("t1"));
  app.clientSecretHash = "hash";
  assert(toOData(app)["clientSecret"].type == Json.Type.null_);
  assert(toOData(app, "plain")["clientSecret"].get!string == "plain");
  assert(odataTime(SysTime.fromISOExtString("2026-11-09T10:00:00Z").stdTime).get!string == "2026-11-09T10:00:00Z");
}
