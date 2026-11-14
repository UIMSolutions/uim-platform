/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Request / response models of the authentication and token flows.
module uim.platform.identity_authentication.application.dtos.authentication;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Form login (user name or e-mail + password, optional one-time code).
struct AuthRequest {
  TenantId tenantId;
  ApplicationId applicationId;
  /// E-mail address or user name.
  string email;
  string password;
  string mfaCode;
  string ipAddress;
  string userAgent;
}

struct AuthResult {
  bool success;
  string message;
  bool mfaRequired;
  MfaType mfaType = MfaType.none;
  string sessionId;
  UserId userId;
  RiskLevel riskLevel = RiskLevel.low;
  long expiresAt;
  /// HTTP-like status: 200 ok, 401 credentials / MFA, 403 not allowed, 423 locked.
  int code = 401;

  bool hasError() const {
    return !success;
  }

  Json toJson() const {
    auto j = Json.emptyObject
      .set("success", success)
      .set("message", message);
    if (mfaRequired)
      j.set("mfaRequired", true).set("mfaType", enumValue(mfaType));
    if (success)
      j.set("sessionId", sessionId)
        .set("userId", userId.value)
        .set("riskLevel", enumValue(riskLevel))
        .set("expiresAt", expiresAt);
    return j;
  }
}

/// Authorization: exchange a session for tokens (client authenticates).
struct TokenRequest {
  TenantId tenantId;
  SessionId sessionId;
  string clientId;
  string clientSecret;
  string[] scopes;
  string ipAddress;
}

/// refresh_token grant.
struct RefreshRequest {
  TenantId tenantId;
  string refreshToken;
  string clientId;
  string clientSecret;
  string[] scopes;
}

/// OAuth 2.0 token response (RFC 6749 §5.1 / §5.2).
struct TokenResponse {
  TenantId tenantId;
  string accessToken;
  string refreshToken;
  string idToken;
  long expiresIn;
  string[] scopes;
  /// OAuth error code (invalid_grant, invalid_client, invalid_scope, access_denied) — "" on success.
  string error;
  string errorDescription;
  int code = 200;

  bool isSuccess() const {
    return error.length == 0;
  }

  static TokenResponse failure(string error, string description, int code = 400) {
    TokenResponse r;
    r.error = error;
    r.errorDescription = description;
    r.code = code;
    return r;
  }

  Json toJson() const {
    if (!isSuccess)
      return Json.emptyObject.set("error", error).set("error_description", errorDescription);
    return Json.emptyObject
      .set("access_token", accessToken)
      .set("refresh_token", refreshToken)
      .set("id_token", idToken)
      .set("token_type", "Bearer")
      .set("expires_in", expiresIn)
      .set("scope", scopes.join(" "));
  }
}

/// Token introspection response (RFC 7662).
struct TokenIntrospection {
  bool active;
  string subject;
  string clientId;
  string userName;
  TenantId tenantId;
  TokenType tokenType;
  string[] scopes;
  long issuedAt; /// stdTime
  long expiresAt; /// stdTime

  Json toJson() const {
    if (!active)
      return Json.emptyObject.set("active", false);
    return Json.emptyObject
      .set("active", true)
      .set("sub", subject)
      .set("client_id", clientId)
      .set("username", userName)
      .set("zid", tenantId.value)
      .set("token_type", enumValue(tokenType))
      .set("scope", scopes.join(" "))
      .set("iat", toUnixSeconds(issuedAt))
      .set("exp", toUnixSeconds(expiresAt));
  }
}

struct ChangePasswordRequest {
  TenantId tenantId;
  UserId userId;
  string oldPassword;
  string newPassword;
}

/// stdTime (hnsecs since 0001-01-01) → Unix seconds.
long toUnixSeconds(long stdTime) pure nothrow {
  enum long unixEpochStdTime = 621_355_968_000_000_000L;
  return stdTime <= 0 ? 0 : (stdTime - unixEpochStdTime) / 10_000_000L;
}

/// Unix seconds → stdTime.
long fromUnixSeconds(long seconds) pure nothrow {
  enum long unixEpochStdTime = 621_355_968_000_000_000L;
  return seconds <= 0 ? 0 : seconds * 10_000_000L + unixEpochStdTime;
}
///
unittest {
  mixin(ShowTest!("authentication dtos"));

  assert(toUnixSeconds(fromUnixSeconds(1_794_243_845)) == 1_794_243_845);
  auto r = TokenResponse.failure("invalid_client", "bad secret", 401);
  assert(!r.isSuccess && r.toJson["error"].get!string == "invalid_client");
  assert(TokenIntrospection.init.toJson["active"].get!bool == false);
}
