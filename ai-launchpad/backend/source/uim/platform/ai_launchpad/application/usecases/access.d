/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Built-in login (authMode "jwt"), user administration and roles.
///
/// Credentials are checked against salted PBKDF2 hashes; unknown users and
/// wrong passwords give the same answer (and take the same time). Too many
/// failed logins lock the account temporarily. A user's scopes are the
/// union of the scopes of the assigned roles. There is always at least one
/// unlocked user with the Admin scope: the last one can neither be deleted,
/// locked nor lose it — also not by changing or deleting a role.
module uim.platform.ai_launchpad.application.usecases.access;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum string invalidCredentials = "Invalid user name or password";

class AccessUseCase : AilpInteractor, IAuthenticate, IManageUsers {
  protected IPasswordHasher hasher;
  protected ITokenIssuer issuer;
  protected string dummyHash; /// verified for unknown users (equal timing)

  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy,
    IPasswordHasher hasher, ITokenIssuer issuer) {
    super(repos, clock, audit, unitOfWork, policy);
    this.hasher = hasher;
    this.issuer = issuer;
  }

  // ── IAuthenticate ────────────────────────────────────────────────────────

  LoginResult login(LoginRequest r) {
    if (issuer is null)
      throw AilpException.ruleViolation("The built-in login is disabled (authMode is not 'jwt')");
    auto name = r.username.strip;
    auto user = isValidId(name) ? repos.users.findById(r.tenantId, UserAccountId(name)) : UserAccount.init;
    auto at = now;
    auto who = UserId(name.length <= maxIdLength ? name : name[0 .. maxIdLength]);
    if (user.isNull) {
      if (dummyHash.length == 0)
        dummyHash = hasher.hash("dummy password for timing");
      hasher.verify(r.password, dummyHash);
      emit("login.failed", r.tenantId, who, who.value, Json(["reason": Json("unknown user")]));
      throw AilpException.unauthorized(invalidCredentials);
    }
    if (user.isLockedAt(at)) {
      emit("login.failed", r.tenantId, who, who.value, Json(["reason": Json("locked")]));
      throw AilpException.unauthorized("The account is locked");
    }
    if (!hasher.verify(r.password, user.passwordHash)) {
      user.recordFailure(at, policy.maxFailedLogins, policy.lockSeconds);
      repos.users.save(user);
      auto locked = user.isLockedAt(at);
      emit(locked ? "login.locked" : "login.failed", r.tenantId, who, who.value, Json(["reason": Json("password")]));
      throw AilpException.unauthorized(invalidCredentials);
    }
    auto scopes = scopesOf(r.tenantId, user);
    if (scopes.length == 0) {
      emit("login.failed", r.tenantId, who, who.value, Json(["reason": Json("no scopes")]));
      throw AilpException.unauthorized("The account has no roles with scopes");
    }
    user.recordSuccess(at);
    if (hasher.needsRehash(user.passwordHash))
      user.passwordHash = hasher.hash(r.password);
    repos.users.save(user);
    LoginResult result;
    result.user = user;
    result.scopes = scopes;
    result.token = issuer.issue(r.tenantId, user, scopes);
    emit("login.succeeded", r.tenantId, who, who.value);
    return result;
  }

  void changePassword(ChangePasswordRequest r) {
    auto user = repos.users.findById(r.tenantId, UserAccountId(r.actor.value));
    if (user.isNull || !hasher.verify(r.currentPassword, user.passwordHash)) {
      emit("password.failed", r.tenantId, r.actor, r.actor.value);
      throw AilpException.unauthorized("The current password is wrong");
    }
    requirePasswordStrength(r.newPassword, policy.minPasswordLength);
    user.passwordHash = hasher.hash(r.newPassword);
    stampUpdated(user, r.actor, now);
    repos.users.save(user);
    emit("password.changed", r.tenantId, r.actor, user.id.value);
  }

  // ── IManageUsers ─────────────────────────────────────────────────────────

  UserAccount createUser(CreateUserRequest r) {
    auto id = r.id.strip;
    requireId(id, "User name");
    if (repos.users.existsById(r.tenantId, UserAccountId(id)))
      throw AilpException.conflict("User '" ~ id ~ "' already exists");
    requirePasswordStrength(r.password, policy.minPasswordLength);
    UserAccount u;
    stampCreated!(UserAccount, UserAccountId)(u, r.tenantId, r.actor, id, nextTime);
    u.displayName = r.displayName.strip.length ? r.displayName.strip : id;
    u.email = r.email.strip;
    u.passwordHash = hasher.hash(r.password);
    u.roles = knownRoles(r.tenantId, r.roles.length ? r.roles : [viewerRole]);
    u.locked = r.locked;
    u.validate();
    repos.users.save(u);
    emit("user.created", r.tenantId, r.actor, id, Json(["roles": Json(u.roles.join(" "))]));
    return u;
  }

  UserAccount updateUser(UpdateUserRequest r) {
    auto u = getUser(r.tenantId, UserAccountId(r.id));
    auto wasAdmin = isActiveAdmin(r.tenantId, u);
    r.displayName.applyTo(u.displayName);
    if (r.email.isSet)
      u.email = r.email.value.strip;
    if (r.password.isSet) {
      requirePasswordStrength(r.password.value, policy.minPasswordLength);
      u.passwordHash = hasher.hash(r.password.value);
      u.failedLogins = 0;
      u.lockedUntil = 0;
    }
    if (r.roles.isSet)
      u.roles = knownRoles(r.tenantId, r.roles.value);
    if (r.locked.isSet)
      u.locked = r.locked.value;
    if (u.locked && u.id.value == r.actor.value)
      throw AilpException.ruleViolation("You cannot lock your own account");
    if (wasAdmin && !isActiveAdmin(r.tenantId, u))
      requireAnotherAdmin(r.tenantId, u.id);
    u.validate();
    stampUpdated(u, r.actor, now);
    repos.users.save(u);
    string[] fields;
    foreach (name, set; ["displayName": r.displayName.isSet, "email": r.email.isSet, "password": r.password.isSet,
        "roles": r.roles.isSet, "locked": r.locked.isSet])
      if (set)
        fields ~= name;
    emit(r.locked.isSet && u.locked ? "user.locked" : "user.updated", r.tenantId, r.actor, u.id.value,
      Json(["fields": Json(fields.sort.join(","))]));
    return u;
  }

  UserAccount getUser(TenantId t, UserAccountId id) {
    return required(repos.users.findById(t, id), "User '" ~ id.value ~ "'");
  }

  UserAccount[] listUsers(TenantId t) {
    return repos.users.findAll(t);
  }

  string[] scopesOf(TenantId t, const UserAccount u) {
    return effectiveScopes(repos.roles.findAll(t), u.roles);
  }

  void deleteUser(TenantId t, UserAccountId id, UserId actor) {
    auto u = getUser(t, id);
    if (id.value == actor.value)
      throw AilpException.ruleViolation("You cannot delete your own account");
    if (isActiveAdmin(t, u))
      requireAnotherAdmin(t, id);
    repos.users.removeById(t, id);
    emit("user.deleted", t, actor, id.value);
  }

  bool ensureAdministrator(TenantId t, string name, string password) {
    if (repos.users.countAll(t) > 0)
      return false;
    CreateUserRequest r;
    r.tenantId = t;
    r.actor = UserId(systemActor);
    r.id = name;
    r.displayName = "Administrator";
    r.password = password;
    r.roles = [administratorRole];
    createUser(r);
    return true;
  }

  IssuedToken issueToken(TenantId t, UserAccountId id) {
    if (issuer is null)
      throw AilpException.ruleViolation("Tokens need authMode 'jwt'");
    auto u = getUser(t, id);
    if (u.isLockedAt(now))
      throw AilpException.ruleViolation("The account of '" ~ id.value ~ "' is locked");
    auto token = issuer.issue(t, u, scopesOf(t, u));
    emit("token.issued", t, UserId("cli"), id.value);
    return token;
  }

  protected string[] knownRoles(TenantId t, const string[] requested) {
    string[] roles;
    foreach (r; requested) {
      auto id = r.strip;
      if (id.length == 0 || roles.canFind(id))
        continue;
      required(repos.roles.findById(t, RoleId(id)), "Role '" ~ id ~ "'");
      roles ~= id;
    }
    return roles;
  }

  protected bool isActiveAdmin(TenantId t, const UserAccount u) {
    return !u.locked && scopesOf(t, u).canFind(adminScope);
  }

  protected void requireAnotherAdmin(TenantId t, UserAccountId except) {
    foreach (other; repos.users.findAll(t))
      if (other.id != except && isActiveAdmin(t, other))
        return;
    throw AilpException.ruleViolation("The last administrator cannot be removed, locked or lose the Admin scope");
  }
}

class ManageRolesUseCase : ResourceInteractor!(Role, RoleId, RoleInput), IManageRoles {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(Role, RoleId) store() {
    return repos.roles;
  }

  protected override string what() {
    return "Role";
  }

  protected override string eventPrefix() {
    return "role";
  }

  protected override RoleInput toInput(const Role e) {
    return RoleInput(e.name, e.description, e.scopes.dup);
  }

  protected override void fromInput(TenantId t, ref Role e, RoleInput i, bool creating) {
    e.name = i.name.strip.length ? i.name.strip : e.id.value;
    e.description = i.description.strip;
    e.scopes = normalizeScopes(i.scopes);
    if (creating)
      e.builtIn = false;
  }

  protected override void beforeSave(TenantId t, ref Role e, bool creating, const string[] changed) {
    if (creating || !changed.canFind("scopes"))
      return;
    if (e.builtIn && e.id.value == administratorRole && e.scopes != knownScopes)
      throw AilpException.ruleViolation("The scopes of the built-in Administrator role cannot be changed");
    if (!e.grants(adminScope))
      requireAdminWithout(t, e.id.value);
  }

  protected override void beforeRemove(TenantId t, const Role e, UserId actor) {
    if (e.builtIn)
      throw AilpException.ruleViolation("The built-in role '" ~ e.id.value ~ "' cannot be deleted");
    requireUnused("Role '" ~ e.id.value ~ "'", repos.users.findAll(t).count!(u => u.hasRole(e.id.value)), "users");
  }

  size_t ensureBuiltInRoles(TenantId t) {
    size_t n;
    batch(() {
      foreach (d; builtInRoleDefinitions) {
        if (repos.roles.existsById(t, RoleId(d.id)))
          continue;
        Role r;
        stampCreated!(Role, RoleId)(r, t, UserId(systemActor), d.id, nextTime);
        r.name = d.name;
        r.description = d.description;
        r.scopes = d.scopes.dup;
        r.builtIn = true;
        r.validate();
        repos.roles.save(r);
        n++;
      }
    });
    return n;
  }

  /// Some unlocked user keeps the Admin scope through another role.
  protected void requireAdminWithout(TenantId t, string roleId) {
    auto roles = repos.roles.findAll(t).filter!(r => r.id.value != roleId).array;
    foreach (u; repos.users.findAll(t))
      if (!u.locked && effectiveScopes(roles, u.roles).canFind(adminScope))
        return;
    if (repos.users.countAll(t) == 0)
      return;
    throw AilpException.ruleViolation("Without the Admin scope of role '" ~ roleId ~ "' no administrator would remain");
  }
}
