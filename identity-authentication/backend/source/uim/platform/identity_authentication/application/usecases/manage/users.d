/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.users;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// SCIM-like user management: CRUD, lifecycle, passwords and MFA enrollment.
class ManageUsersUseCase : IManageUsersUseCase {
  protected IUserRepository repo;
  protected IPasswordService passwords;
  protected IMfaService mfa;
  protected IGroupRepository groups;
  protected ISessionRepository sessions;
  protected ITokenRepository tokens;
  protected IIdentityEventPublisher events;
  protected AuthenticationSettings settings;

  /// groups / sessions / tokens may be null (no cascading).
  this(IUserRepository repo, IPasswordService passwords, IMfaService mfa = null,
      IGroupRepository groups = null, ISessionRepository sessions = null, ITokenRepository tokens = null,
      IIdentityEventPublisher events = null, AuthenticationSettings settings = AuthenticationSettings.init) {
    this.repo = repo;
    this.passwords = passwords;
    this.mfa = mfa;
    this.groups = groups;
    this.sessions = sessions;
    this.tokens = tokens;
    this.events = events is null ? new NullEventPublisher : events;
    this.settings = settings;
  }

  IAUser[] listUsers(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  IAUser[] listByStatus(TenantId tenantId, UserStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  IAUser[] listByGroup(TenantId tenantId, GroupId groupId) {
    return repo.findByGroupId(tenantId, groupId);
  }

  IAUser getUser(TenantId tenantId, UserId id) {
    return repo.findById(tenantId, id);
  }

  IAUser findUser(TenantId tenantId, string emailOrUserName) {
    auto key = emailOrUserName.strip;
    auto user = repo.findByEmail(tenantId, key);
    return user.isNull ? repo.findByUserName(tenantId, key) : user;
  }

  UsecaseResult createUser(UserDTO dto) {
    return guarded(() {
      if (!dto.userId.isNull && repo.existsById(dto.tenantId, dto.userId))
        return conflict("User '" ~ dto.userId.value ~ "' already exists");

      auto user = newEntity!IAUser(dto.tenantId, dto.userId, dto.createdBy);
      user.status = UserStatus.active;
      string[] errors;
      apply(user, dto, errors);
      if (user.userName.length == 0 && user.email.canFind('@'))
        user.userName = user.email[0 .. user.email.indexOf('@')];
      errors ~= IdentityValidator.validate(user);
      errors ~= IdentityValidator.validatePassword(dto.password, settings.passwordMinLength);
      if (errors.length)
        return invalid(errors);
      if (repo.existsByEmail(dto.tenantId, user.email))
        return conflict("A user with e-mail '" ~ user.email ~ "' already exists");
      if (repo.existsByUserName(dto.tenantId, user.userName))
        return conflict("A user with user name '" ~ user.userName ~ "' already exists");

      user.passwordHash = passwords.hashPassword(dto.password);
      user.passwordChangedAt = nowStdTime();
      user.globalUserId = UserId(generateId);
      repo.save(user);
      events.publish(IdentityTopics.userCreated, Json.emptyObject
          .set("tenantId", dto.tenantId.value).set("userId", user.id.value).set("userName", user.userName));
      return created(user.id.value, "User created");
    });
  }

  UsecaseResult updateUser(UserDTO dto) {
    return guarded(() {
      auto user = repo.findById(dto.tenantId, dto.userId);
      if (user.isNull)
        return notFound("User", dto.userId.value);

      auto previousEmail = user.email;
      auto previousName = user.userName;
      auto previousStatus = user.status;
      string[] errors;
      apply(user, dto, errors);
      UserStatus status = user.status;
      if (readEnum(dto.status, status, "status", errors))
        ensureTransition("User", previousStatus, status);
      user.status = status;
      errors ~= IdentityValidator.validate(user);
      if (errors.length)
        return invalid(errors);
      if (user.email != previousEmail && repo.existsByEmail(dto.tenantId, user.email))
        return conflict("A user with e-mail '" ~ user.email ~ "' already exists");
      if (user.userName != previousName && repo.existsByUserName(dto.tenantId, user.userName))
        return conflict("A user with user name '" ~ user.userName ~ "' already exists");

      touch(user, dto.updatedBy);
      repo.update(user);
      if (status != previousStatus)
        afterStatusChange(user, previousStatus);
      return succeeded(user.id.value, "User updated");
    });
  }

  UsecaseResult setUserStatus(TenantId tenantId, UserId id, UserStatus status, UserId by) {
    return guarded(() {
      auto user = repo.findById(tenantId, id);
      if (user.isNull)
        return notFound("User", id.value);
      auto previous = user.status;
      ensureTransition("User", previous, status);
      user.status = status;
      if (status == UserStatus.active)
        user.failedLoginAttempts = 0;
      touch(user, by);
      repo.update(user);
      afterStatusChange(user, previous);
      return succeeded(user.id.value, "User is now " ~ enumValue(status));
    });
  }

  UsecaseResult changePassword(ChangePasswordRequest req) {
    auto user = repo.findById(req.tenantId, req.userId);
    if (user.isNull)
      return notFound("User", req.userId.value);
    if (!passwords.verifyPassword(req.oldPassword, user.passwordHash))
      return UsecaseResult(false, user.id.value, "Current password is incorrect", 401);
    if (req.oldPassword == req.newPassword)
      return invalid("the new password must differ from the current one");
    return setPassword(user, req.newPassword, req.userId, false);
  }

  UsecaseResult resetPassword(TenantId tenantId, UserId id, string newPassword, UserId by) {
    auto user = repo.findById(tenantId, id);
    if (user.isNull)
      return notFound("User", id.value);
    return setPassword(user, newPassword, by, true);
  }

  UsecaseResult enrollMfa(TenantId tenantId, UserId id, MfaType mfaType, UserId by) {
    if (mfa is null)
      return rejected("MFA is not available");
    if (mfaType == MfaType.none)
      return invalid("mfaType must be one of totp, sms, email");
    auto user = repo.findById(tenantId, id);
    if (user.isNull)
      return notFound("User", id.value);
    if (mfaType == MfaType.sms && user.phoneNumber.length == 0)
      return rejected("SMS requires a phone number");

    user.mfaType = mfaType;
    user.mfaSecret = mfa.generateSecret(mfaType);
    touch(user, by);
    repo.update(user);
    events.publish(IdentityTopics.mfaEnrolled, Json.emptyObject
        .set("tenantId", tenantId.value).set("userId", id.value).set("mfaType", enumValue(mfaType)));

    auto data = Json.emptyObject.set("mfaType", enumValue(mfaType));
    if (mfaType == MfaType.totp)
      data.set("secret", user.mfaSecret)
        .set("provisioningUri", mfa.provisioningUri(user.mfaSecret, user.email, settings.issuer));
    return succeeded(user.id.value, "MFA (" ~ enumValue(mfaType) ~ ") enrolled", 200, data);
  }

  UsecaseResult disableMfa(TenantId tenantId, UserId id, UserId by) {
    auto user = repo.findById(tenantId, id);
    if (user.isNull)
      return notFound("User", id.value);
    user.mfaType = MfaType.none;
    user.mfaSecret = "";
    touch(user, by);
    repo.update(user);
    events.publish(IdentityTopics.mfaDisabled, Json.emptyObject
        .set("tenantId", tenantId.value).set("userId", id.value));
    return succeeded(user.id.value, "MFA disabled");
  }

  UsecaseResult deleteUser(TenantId tenantId, UserId id) {
    auto user = repo.findById(tenantId, id);
    if (user.isNull)
      return notFound("User", id.value);
    if (groups !is null)
      foreach (g; groups.findByMember(tenantId, id)) {
        g.memberUserIds = g.memberUserIds.filter!(m => m != id).array;
        groups.update(g);
      }
    revokeAccess(tenantId, id);
    repo.remove(user);
    return succeeded(id.value, "User deleted");
  }

  // ── helpers ────────────────────────────────────────────────────────────

  protected UsecaseResult setPassword(IAUser user, string newPassword, UserId by, bool byAdmin) {
    auto errors = IdentityValidator.validatePassword(newPassword, settings.passwordMinLength);
    if (errors.length)
      return invalid(errors);
    user.passwordHash = passwords.hashPassword(newPassword);
    user.passwordChangedAt = nowStdTime();
    if (byAdmin)
      user.failedLoginAttempts = 0;
    touch(user, by);
    repo.update(user);
    // other sessions must sign in again with the new password
    revokeAccess(user.tenantId, user.id);
    events.publish(IdentityTopics.passwordChanged, Json.emptyObject
        .set("tenantId", user.tenantId.value).set("userId", user.id.value).set("reset", byAdmin));
    return succeeded(user.id.value, byAdmin ? "Password reset" : "Password changed");
  }

  protected void afterStatusChange(const IAUser user, UserStatus previous) {
    if (user.status == UserStatus.inactive || user.status == UserStatus.locked)
      revokeAccess(user.tenantId, user.id);
    events.publish(IdentityTopics.userStatusChanged, Json.emptyObject
        .set("tenantId", user.tenantId.value).set("userId", user.id.value)
        .set("from", enumValue(previous)).set("to", enumValue(user.status)));
  }

  protected void revokeAccess(TenantId tenantId, UserId id) {
    if (sessions !is null)
      sessions.revokeAllForUser(tenantId, id);
    if (tokens !is null)
      tokens.revokeAllForUser(tenantId, id);
  }

  protected void apply(ref IAUser user, const UserDTO dto, ref string[] errors) {
    assignIf(user.userName, dto.userName.strip);
    assignIf(user.email, dto.email.strip.toLower);
    assignIf(user.firstName, dto.firstName);
    assignIf(user.lastName, dto.lastName);
    assignIf(user.phoneNumber, dto.phoneNumber);
    assignIf(user.externalIdpId, dto.externalIdpId);
  }
}

///
unittest {
  mixin(ShowTest!("ManageUsersUseCase"));

  auto sessions = new SessionRepository();
  auto uc = new ManageUsersUseCase(new UserRepository(), new Pbkdf2PasswordService(1_000), new TotpMfaService(),
    new GroupRepository(), sessions, new TokenRepository());
  auto t = TenantId("t1");

  UserDTO dto;
  dto.tenantId = t;
  dto.email = "Jane.Doe@Example.com";
  dto.firstName = "Jane";
  dto.password = "Secret123";
  auto r = uc.createUser(dto);
  assert(r.isSuccess, r.message);
  auto id = UserId(r.id);
  auto user = uc.getUser(t, id);
  assert(user.email == "jane.doe@example.com" && user.userName == "jane.doe");
  assert(user.passwordHash.startsWith("pbkdf2-sha256$"));
  assert(uc.findUser(t, "jane.doe").id == id);

  assert(uc.createUser(dto).code == 409); // duplicate e-mail
  dto.email = "x@example.com";
  dto.password = "short";
  assert(uc.createUser(dto).code == 400);

  // lifecycle
  assert(uc.setUserStatus(t, id, UserStatus.locked, UserId("admin")).isSuccess);
  assert(uc.setUserStatus(t, id, UserStatus.pendingVerification, UserId("admin")).code == 422);
  assert(uc.setUserStatus(t, id, UserStatus.active, UserId("admin")).isSuccess);

  // passwords
  ChangePasswordRequest change = {tenantId: t, userId: id, oldPassword: "wrong", newPassword: "Another456"};
  assert(uc.changePassword(change).code == 401);
  change.oldPassword = "Secret123";
  assert(uc.changePassword(change).isSuccess);
  assert(uc.resetPassword(t, id, "abc", UserId("admin")).code == 400);

  // MFA
  auto mfa = uc.enrollMfa(t, id, MfaType.totp, UserId("admin"));
  assert(mfa.isSuccess && mfa.data["provisioningUri"].get!string.startsWith("otpauth://totp/"));
  assert(uc.getUser(t, id).hasMfa);
  assert(uc.enrollMfa(t, id, MfaType.sms, UserId("admin")).code == 422); // no phone number
  assert(uc.disableMfa(t, id, UserId("admin")).isSuccess);
  assert(!uc.getUser(t, id).hasMfa);

  assert(uc.deleteUser(t, id).isSuccess);
  assert(uc.getUser(t, id).isNull);
}
