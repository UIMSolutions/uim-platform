/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.authenticate_user;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Form login with account lockout, risk-based authentication and MFA.
///
/// 1. find the user by e-mail or user name (unknown users cost the same time)
/// 2. reject locked / inactive users
/// 3. verify the password — failures count towards the lockout
/// 4. evaluate the risk rules (may deny or demand a second factor)
/// 5. demand / verify the one-time code (SMS / e-mail codes are sent on demand)
/// 6. open an SSO session
class AuthenticateUserUseCase : IAuthenticationUseCase {
  protected IUserRepository users;
  protected IGroupRepository groups;
  protected ISessionRepository sessions;
  protected ITokenRepository tokens;
  protected IRiskRuleRepository riskRules;
  protected IPasswordService passwords;
  protected IMfaService mfa;
  protected IIdentityEventPublisher events;
  protected AuthenticationSettings settings;
  /// Verified for unknown users so that response times do not reveal accounts.
  protected string dummyHash;

  this(IUserRepository users, IGroupRepository groups, ISessionRepository sessions, ITokenRepository tokens,
      IRiskRuleRepository riskRules, IPasswordService passwords, IMfaService mfa,
      IIdentityEventPublisher events = null, AuthenticationSettings settings = AuthenticationSettings.init) {
    this.users = users;
    this.groups = groups;
    this.sessions = sessions;
    this.tokens = tokens;
    this.riskRules = riskRules;
    this.passwords = passwords;
    this.mfa = mfa;
    this.events = events is null ? new NullEventPublisher : events;
    this.settings = settings;
    this.dummyHash = passwords.hashPassword("dummy-password-for-timing");
  }

  AuthResult login(AuthRequest req) {
    AuthResult fail(string message, int code = 401) {
      AuthResult r;
      r.message = message;
      r.code = code;
      return r;
    }

    if (req.email.strip.length == 0 || req.password.length == 0)
      return fail("E-mail / user name and password are required", 400);

    auto user = req.email.canFind('@')
      ? users.findByEmail(req.tenantId, req.email.strip)
      : users.findByUserName(req.tenantId, req.email.strip);
    if (user.isNull) {
      passwords.verifyPassword(req.password, dummyHash);
      audit(IdentityTopics.loginFailed, req, UserId(""), "unknown user");
      return fail("Invalid credentials");
    }

    if (user.status == UserStatus.locked) {
      audit(IdentityTopics.loginFailed, req, user.id, "locked");
      return fail("User account is locked", 423);
    }
    if (!user.isActive) {
      audit(IdentityTopics.loginFailed, req, user.id, enumValue(user.status));
      return fail("User account is not active", 403);
    }

    if (!passwords.verifyPassword(req.password, user.passwordHash))
      return failedAttempt(user, req, "Invalid credentials");

    // ── risk-based authentication ─────────────────────────────────────
    RiskEvaluationContext ctx;
    ctx.ipAddress = req.ipAddress;
    ctx.userAgent = req.userAgent;
    ctx.authMethod = AuthMethod.form;
    ctx.userGroups = groupKeysOf(groups, user);
    auto risk = assessRisk(riskRules.findByTenant(req.tenantId), user, ctx);
    if (risk.denied) {
      audit(IdentityTopics.loginFailed, req, user.id, "denied by risk rule");
      return fail("Access denied by risk policy", 403);
    }

    // ── second factor ─────────────────────────────────────────────────
    MfaType mfaUsed = MfaType.none;
    if (user.hasMfa || risk.requiredMfa != MfaType.none) {
      if (!user.hasMfa) {
        audit(IdentityTopics.loginFailed, req, user.id, "mfa enrollment required");
        return fail("A second factor (" ~ enumValue(risk.requiredMfa) ~ ") is required but not enrolled", 403);
      }
      auto now = nowStdTime();
      if (req.mfaCode.length == 0) {
        if (user.mfaType == MfaType.sms || user.mfaType == MfaType.email)
          mfa.sendOtp(user.mfaType, user.mfaType == MfaType.sms ? user.phoneNumber : user.email,
            mfa.currentCode(user.mfaType, user.mfaSecret, now));
        auto r = fail("MFA code required");
        r.mfaRequired = true;
        r.mfaType = user.mfaType;
        r.userId = user.id;
        return r;
      }
      if (!mfa.validateCode(user.mfaType, user.mfaSecret, req.mfaCode.strip, now))
        return failedAttempt(user, req, "Invalid MFA code");
      mfaUsed = user.mfaType;
    }

    // ── success: open the session ─────────────────────────────────────
    auto now = nowStdTime();
    user.failedLoginAttempts = 0;
    user.lastLoginAt = now;
    users.update(user);

    auto session = IASession(req.tenantId, SessionId(generateId), user.id);
    session.userId = user.id;
    session.applicationId = req.applicationId;
    session.authMethod = AuthMethod.form;
    session.mfaUsed = mfaUsed;
    session.ipAddress = req.ipAddress;
    session.userAgent = req.userAgent;
    session.riskLevel = risk.level;
    session.expiresAt = now + settings.sessionTimeoutMinutes * hnsecsPerMinute;
    sessions.save(session);
    audit(IdentityTopics.loginSucceeded, req, user.id, "", session.id.value);

    AuthResult ok;
    ok.success = true;
    ok.code = 200;
    ok.message = "Authentication successful";
    ok.sessionId = session.id.value;
    ok.userId = user.id;
    ok.riskLevel = risk.level;
    ok.mfaType = mfaUsed;
    ok.expiresAt = session.expiresAt;
    return ok;
  }

  UsecaseResult logout(TenantId tenantId, SessionId sessionId) {
    auto session = sessions.findById(tenantId, sessionId);
    if (session.isNull)
      return notFound("Session", sessionId.value);
    sessions.revoke(tenantId, sessionId);
    if (tokens !is null)
      tokens.revokeAllForSession(tenantId, sessionId);
    events.publish(IdentityTopics.logout, Json.emptyObject
        .set("tenantId", tenantId.value).set("sessionId", sessionId.value).set("userId", session.userId.value));
    return succeeded(sessionId.value, "Logged out");
  }

  protected AuthResult failedAttempt(IAUser user, AuthRequest req, string message) {
    user.failedLoginAttempts++;
    bool locked = settings.maxFailedLogins > 0 && user.failedLoginAttempts >= settings.maxFailedLogins;
    if (locked)
      user.status = UserStatus.locked;
    users.update(user);
    audit(IdentityTopics.loginFailed, req, user.id, message);
    if (locked)
      events.publish(IdentityTopics.userLocked, Json.emptyObject
          .set("tenantId", req.tenantId.value).set("userId", user.id.value)
          .set("failedLoginAttempts", user.failedLoginAttempts));

    AuthResult r;
    r.message = locked ? "Too many failed attempts — the account has been locked" : message;
    r.code = locked ? 423 : 401;
    return r;
  }

  protected void audit(string topic, const AuthRequest req, UserId userId, string reason, string sessionId = "") {
    auto payload = Json.emptyObject
      .set("tenantId", req.tenantId.value)
      .set("userId", userId.value)
      .set("login", req.email)
      .set("ipAddress", req.ipAddress);
    if (reason.length)
      payload["reason"] = reason;
    if (sessionId.length)
      payload["sessionId"] = sessionId;
    events.publish(topic, payload);
  }
}
