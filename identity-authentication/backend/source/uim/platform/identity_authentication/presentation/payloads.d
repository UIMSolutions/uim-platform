/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Reading request payloads (JSON objects) into use case DTOs. Shared by the
/// REST, vibe.d REST-interface, OData, CLI and GUI adapters. Only keys that are
/// present are copied, so the same readers serve create (POST) and merge
/// (PATCH / PUT) requests: for updates the DTO is first filled from the entity.
module uim.platform.identity_authentication.presentation.payloads;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Invalid request payload — reported as HTTP 400.
class PayloadException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

bool hasValue(Json body, string key) {
  if (body.type != Json.Type.object)
    return false;
  auto v = key in body;
  return v !is null && v.type != Json.Type.undefined && v.type != Json.Type.null_;
}

/// Copy a string property (numbers / booleans are stringified).
void readString(Json body, string key, ref string target) {
  if (!hasValue(body, key))
    return;
  auto v = body[key];
  target = v.type == Json.Type.string ? v.get!string : v.toString;
}

string stringOf(Json body, string key, string fallback = "") {
  auto value = fallback;
  readString(body, key, value);
  return value;
}

void readBool(Json body, string key, ref bool target) {
  if (!hasValue(body, key))
    return;
  auto v = body[key];
  if (v.type == Json.Type.bool_)
    target = v.get!bool;
  else if (v.type == Json.Type.string)
    target = ["true", "1", "yes", "on", "x"].canFind(v.get!string.strip.toLower);
  else if (v.type == Json.Type.int_)
    target = v.get!long != 0;
  else
    throw new PayloadException(key ~ " must be a boolean");
}

void readLong(Json body, string key, ref long target) {
  if (!hasValue(body, key))
    return;
  auto v = body[key];
  try {
    if (v.type == Json.Type.int_)
      target = v.get!long;
    else if (v.type == Json.Type.float_)
      target = cast(long) v.get!double;
    else if (v.type == Json.Type.string)
      target = v.get!string.strip.to!long; // Edm.Int64 with IEEE754Compatible=true
    else
      throw new PayloadException(key ~ " must be a number");
  } catch (ConvException) {
    throw new PayloadException(key ~ " must be a number");
  }
}

void readId(TId)(Json body, string key, ref TId target) {
  string value;
  readString(body, key, value);
  if (value.length)
    target = TId(value.strip);
}

/// A list: JSON array of strings, or a comma / whitespace separated string.
void readStrings(Json body, string key, ref string[] target) {
  if (!hasValue(body, key))
    return;
  auto v = body[key];
  if (v.type == Json.Type.array) {
    string[] values;
    foreach (item; v.get!(Json[]))
      values ~= item.type == Json.Type.string ? item.get!string : item.toString;
    target = values;
  } else if (v.type == Json.Type.string) {
    target = v.get!string.splitter!(c => c == ',' || c == ' ' || c == '\n')
      .map!(s => s.strip).filter!(s => s.length > 0).array;
  } else
    throw new PayloadException(key ~ " must be a list");
}

/// Rules: array of {"attribute","operator","value"} objects or "attr:op:value"
/// strings, or one string with rules separated by ";" or new lines.
void readRules(Json body, string key, ref PolicyRule[] target) {
  if (!hasValue(body, key))
    return;
  PolicyRule[] rules;
  foreach (item; ruleItems(body[key], key)) {
    if (item.type == Json.Type.object)
      rules ~= PolicyRule(stringOf(item, "attribute"), stringOf(item, "operator", stringOf(item, "operator_")),
        stringOf(item, "value"));
    else
      rules ~= PolicyRule.parse(item.get!string);
  }
  target = rules;
}

/// Risk conditions — same formats as readRules (conditionType instead of attribute).
void readConditions(Json body, string key, ref RiskCondition[] target) {
  if (!hasValue(body, key))
    return;
  RiskCondition[] conditions;
  foreach (item; ruleItems(body[key], key)) {
    if (item.type == Json.Type.object)
      conditions ~= RiskCondition(stringOf(item, "conditionType", stringOf(item, "attribute")),
        stringOf(item, "operator", stringOf(item, "operator_")), stringOf(item, "value"));
    else
      conditions ~= RiskCondition.parse(item.get!string);
  }
  target = conditions;
}

private Json[] ruleItems(Json v, string key) {
  if (v.type == Json.Type.array)
    return v.get!(Json[]).filter!(i => i.type == Json.Type.object || i.type == Json.Type.string).array;
  if (v.type == Json.Type.string)
    return v.get!string.splitter!(c => c == ';' || c == '\n')
      .map!(s => s.strip).filter!(s => s.length > 0).map!(s => Json(s)).array;
  throw new PayloadException(key ~ " must be a list of rules");
}

private void requireObject(Json body) {
  if (body.type != Json.Type.object)
    throw new PayloadException("Request body must be a JSON object");
}

void readPayload(ref UserDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.userId);
  readString(body, "userName", d.userName);
  readString(body, "email", d.email);
  readString(body, "firstName", d.firstName);
  readString(body, "lastName", d.lastName);
  readString(body, "password", d.password);
  readString(body, "status", d.status);
  readString(body, "phoneNumber", d.phoneNumber);
  readString(body, "externalIdpId", d.externalIdpId);
}

void readPayload(ref GroupDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.groupId);
  readString(body, "name", d.name);
  readString(body, "description", d.description);
}

void readPayload(ref ApplicationDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.applicationId);
  readString(body, "name", d.name);
  readString(body, "description", d.description);
  readString(body, "protocol", d.protocol);
  readStrings(body, "redirectUris", d.redirectUris);
  readStrings(body, "allowedScopes", d.allowedScopes);
  readString(body, "samlEntityId", d.samlEntityId);
  readString(body, "samlAcsUrl", d.samlAcsUrl);
  readString(body, "samlMetadataUrl", d.samlMetadataUrl);
  readBool(body, "active", d.active);
}

void readPayload(ref PolicyDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.policyId);
  readString(body, "name", d.name);
  readString(body, "description", d.description);
  readRules(body, "rules", d.rules);
  readStrings(body, "applicationIds", d.applicationIds);
  readBool(body, "active", d.active);
}

void readPayload(ref RiskRuleDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.ruleId);
  readString(body, "name", d.name);
  readConditions(body, "conditions", d.conditions);
  readString(body, "riskLevel", d.riskLevel);
  readString(body, "requiredMfa", d.requiredMfa);
  readBool(body, "denyAccess", d.denyAccess);
  readBool(body, "active", d.active);
}

void readPayload(ref IdpConfigDTO d, Json body) {
  requireObject(body);
  readId(body, "id", d.idpId);
  readString(body, "name", d.name);
  readString(body, "idpType", d.idpType);
  readString(body, "metadataUrl", d.metadataUrl);
  readString(body, "authorizationEndpoint", d.authorizationEndpoint);
  readString(body, "tokenEndpoint", d.tokenEndpoint);
  readString(body, "userInfoEndpoint", d.userInfoEndpoint);
  readString(body, "clientId", d.clientId);
  readString(body, "clientSecret", d.clientSecret);
  readStrings(body, "domainHints", d.domainHints);
  readBool(body, "isDefault", d.isDefault);
  readBool(body, "active", d.active);
}

/// Login: "email" (or "userName" / "login"), "password", "mfaCode", "applicationId".
void readPayload(ref AuthRequest d, Json body) {
  requireObject(body);
  readString(body, "login", d.email);
  readString(body, "userName", d.email);
  readString(body, "email", d.email);
  readString(body, "password", d.password);
  readString(body, "mfaCode", d.mfaCode);
  readId(body, "applicationId", d.applicationId);
}

/// Accepts camelCase and OAuth snake_case names; "scope" may be space separated.
void readPayload(ref TokenRequest d, Json body) {
  requireObject(body);
  readId(body, "sessionId", d.sessionId);
  readId(body, "session_id", d.sessionId);
  readString(body, "clientId", d.clientId);
  readString(body, "client_id", d.clientId);
  readString(body, "clientSecret", d.clientSecret);
  readString(body, "client_secret", d.clientSecret);
  readStrings(body, "scopes", d.scopes);
  readStrings(body, "scope", d.scopes);
}

void readPayload(ref RefreshRequest d, Json body) {
  requireObject(body);
  readString(body, "refreshToken", d.refreshToken);
  readString(body, "refresh_token", d.refreshToken);
  readString(body, "clientId", d.clientId);
  readString(body, "client_id", d.clientId);
  readString(body, "clientSecret", d.clientSecret);
  readString(body, "client_secret", d.clientSecret);
  readStrings(body, "scopes", d.scopes);
  readStrings(body, "scope", d.scopes);
}

/// HTTP status for a failed use case result (401/403/404/409/422/423, default 400).
int httpStatusOf(const UsecaseResult result) {
  switch (result.code) {
  case 401, 403, 404, 409, 422, 423:
    return cast(int) result.code;
  default:
    return 400;
  }
}

///
unittest {
  mixin(ShowTest!("payloads"));

  ApplicationDTO app;
  readPayload(app, parseJsonString(`{"name": "Portal", "redirectUris": "https://a/cb, https://b/cb", "active": "false"}`));
  assert(app.name == "Portal" && app.redirectUris == ["https://a/cb", "https://b/cb"] && !app.active);

  PolicyDTO p;
  readPayload(p, parseJsonString(`{"rules": [{"attribute": "group", "operator": "in", "value": "admins"}, "ip_range:in:10.0.0.0/8"]}`));
  assert(p.rules == [PolicyRule("group", "in", "admins"), PolicyRule("ip_range", "in", "10.0.0.0/8")]);
  readPayload(p, parseJsonString(`{"rules": "mfa:eq:true; auth_method:eq:form"}`));
  assert(p.rules.length == 2 && p.rules[1].value == "form");

  RiskRuleDTO r;
  readPayload(r, parseJsonString(`{"conditions": ["failed_logins:ge:3"], "denyAccess": true}`));
  assert(r.conditions == [RiskCondition("failed_logins", "ge", "3")] && r.denyAccess);

  TokenRequest t;
  readPayload(t, parseJsonString(`{"session_id": "s1", "client_id": "c", "scope": "openid profile"}`));
  assert(t.sessionId.value == "s1" && t.clientId == "c" && t.scopes == ["openid", "profile"]);

  bool failed;
  try
    readPayload(app, parseJsonString(`[]`));
  catch (PayloadException)
    failed = true;
  assert(failed);
  assert(httpStatusOf(UsecaseResult(false, "", "x", 423)) == 423);
  assert(httpStatusOf(UsecaseResult(false, "", "x", 500)) == 400);
}
