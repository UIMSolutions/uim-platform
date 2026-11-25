/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Built-in login (authMode "jwt") and user administration.
///
/// Credentials are checked against salted PBKDF2 hashes; unknown users and
/// wrong passwords give the same answer (and take the same time). Too many
/// failed logins lock the account temporarily. The last administrator can
/// neither be deleted, locked nor lose the Admin scope.
module uim.platform.document_ai.application.usecases.access;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum string invalidCredentials = "Invalid user name or password";

class AccessUseCase : DaiInteractor, IAuthenticate, IManageUsers {
  protected IPasswordHasher hasher;
  protected ITokenIssuer issuer;
  protected string dummyHash; /// verified for unknown users (equal timing)

  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy,
    IPasswordHasher hasher, ITokenIssuer issuer) {
    super(repos, clock, events, unitOfWork, policy);
    this.hasher = hasher;
    this.issuer = issuer;
  }

  // ── IAuthenticate ────────────────────────────────────────────────────────

  LoginResult login(LoginRequest r) {
    if (issuer is null)
      throw DaiException.ruleViolation("The built-in login is disabled (authMode is not 'jwt')");
    auto name = r.username.strip;
    auto user = isValidId(name) ? repos.users.findById(r.tenantId, UserAccountId(name)) : UserAccount.init;
    auto at = now;
    if (user.isNull) {
      if (dummyHash.length == 0)
        dummyHash = hasher.hash("dummy password for timing");
      hasher.verify(r.password, dummyHash);
      emit("login.failed", r.tenantId, name, Json(["reason": Json("unknown user")]));
      throw DaiException.unauthorized(invalidCredentials);
    }
    if (user.isLockedAt(at)) {
      emit("login.failed", r.tenantId, name, Json(["reason": Json("locked")]));
      throw DaiException.unauthorized("The account is locked");
    }
    if (!hasher.verify(r.password, user.passwordHash)) {
      user.recordFailure(at, policy.maxFailedLogins, policy.lockSeconds);
      repos.users.save(user);
      emit("login.failed", r.tenantId, name, Json(["reason": Json("password"), "locked": Json(user.isLockedAt(at))]));
      throw DaiException.unauthorized(invalidCredentials);
    }
    user.recordSuccess(at);
    if (hasher.needsRehash(user.passwordHash))
      user.passwordHash = hasher.hash(r.password);
    repos.users.save(user);
    LoginResult result;
    result.user = user;
    result.scopes = user.scopes.dup;
    result.token = issuer.issue(r.tenantId, user, user.scopes);
    emit("login.succeeded", r.tenantId, name);
    return result;
  }

  void changePassword(ChangePasswordRequest r) {
    auto user = repos.users.findById(r.tenantId, UserAccountId(r.actor.value));
    if (user.isNull || !hasher.verify(r.currentPassword, user.passwordHash))
      throw DaiException.unauthorized("The current password is wrong");
    requirePasswordStrength(r.newPassword, policy.minPasswordLength);
    user.passwordHash = hasher.hash(r.newPassword);
    stampUpdated(user, r.actor, now);
    repos.users.save(user);
    emit("user.passwordChanged", r.tenantId, user.id.value);
  }

  // ── IManageUsers ─────────────────────────────────────────────────────────

  UserAccount createUser(CreateUserRequest r) {
    auto id = r.id.strip;
    requireId(id, "User name");
    if (repos.users.existsById(r.tenantId, UserAccountId(id)))
      throw DaiException.conflict("User '" ~ id ~ "' already exists");
    requirePasswordStrength(r.password, policy.minPasswordLength);
    UserAccount u;
    stampCreated!(UserAccount, UserAccountId)(u, r.tenantId, r.actor, id, now);
    u.displayName = r.displayName.strip.length ? r.displayName.strip : id;
    u.passwordHash = hasher.hash(r.password);
    u.scopes = normalizeScopes(r.scopes.length ? r.scopes : [readScope]);
    u.locked = r.locked;
    u.validate();
    repos.users.save(u);
    emit("user.created", r.tenantId, id, Json(["scopes": Json(u.scopes.join(" "))]));
    return u;
  }

  UserAccount updateUser(UpdateUserRequest r) {
    auto u = getUser(r.tenantId, UserAccountId(r.id));
    auto wasAdmin = u.isAdmin && !u.locked;
    r.displayName.applyTo(u.displayName);
    if (r.password.isSet) {
      requirePasswordStrength(r.password.value, policy.minPasswordLength);
      u.passwordHash = hasher.hash(r.password.value);
      u.failedLogins = 0;
      u.lockedUntil = 0;
    }
    if (r.scopes.isSet)
      u.scopes = normalizeScopes(r.scopes.value);
    if (r.locked.isSet)
      u.locked = r.locked.value;
    if (wasAdmin && (!u.isAdmin || u.locked))
      requireAnotherAdmin(r.tenantId, u.id);
    if (u.locked && u.id.value == r.actor.value)
      throw DaiException.ruleViolation("You cannot lock your own account");
    u.validate();
    stampUpdated(u, r.actor, now);
    repos.users.save(u);
    return u;
  }

  UserAccount getUser(TenantId t, UserAccountId id) {
    return required(repos.users.findById(t, id), "User '" ~ id.value ~ "'");
  }

  UserAccount[] listUsers(TenantId t) {
    return repos.users.findAll(t);
  }

  void deleteUser(TenantId t, UserAccountId id, UserId actor) {
    auto u = getUser(t, id);
    if (id.value == actor.value)
      throw DaiException.ruleViolation("You cannot delete your own account");
    if (u.isAdmin && !u.locked)
      requireAnotherAdmin(t, id);
    repos.users.removeById(t, id);
    emit("user.deleted", t, id.value, Json(["by": Json(actor.value)]));
  }

  bool ensureAdministrator(TenantId t, string name, string password) {
    if (repos.users.countAll(t) > 0)
      return false;
    CreateUserRequest r;
    r.tenantId = t;
    r.actor = UserId("system");
    r.id = name;
    r.displayName = "Administrator";
    r.password = password;
    r.scopes = knownScopes.dup;
    createUser(r);
    return true;
  }

  IssuedToken issueToken(TenantId t, UserAccountId id) {
    if (issuer is null)
      throw DaiException.ruleViolation("Tokens need authMode 'jwt' and a jwtSecret");
    auto u = getUser(t, id);
    if (u.isLockedAt(now))
      throw DaiException.ruleViolation("The account of '" ~ id.value ~ "' is locked");
    return issuer.issue(t, u, u.scopes);
  }

  protected void requireAnotherAdmin(TenantId t, UserAccountId except) {
    foreach (other; repos.users.findAll(t))
      if (other.id != except && other.isAdmin && !other.locked)
        return;
    throw DaiException.ruleViolation("The last administrator cannot be removed, locked or lose the Admin scope");
  }
}
