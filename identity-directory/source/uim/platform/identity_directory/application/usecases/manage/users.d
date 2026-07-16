/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.application.usecases.manage.users;
// import uim.platform.identity_directory.domain.entities.user;
// import uim.platform.identity_directory.domain.entities.audit_event;

// import uim.platform.identity_directory.domain.ports.repositories.users;
// import uim.platform.identity_directory.domain.ports.repositories.password_service;
// import uim.platform.identity_directory.domain.ports.repositories.password_policys;
// import uim.platform.identity_directory.domain.ports.repositories.audits;
// import uim.platform.identity_directory.domain.services.password_validator;



import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// Application use case: SCIM 2.0 user management (CRUD + search).
class ManageUsersUseCase { // TODO: UIMUseCase {
  private UserRepository userRepo;
  private PasswordService passwordSvc;
  private PasswordPolicyRepository policyRepo;
  private AuditRepository auditRepo;

  this(UserRepository userRepo, PasswordService passwordSvc,
      PasswordPolicyRepository policyRepo, AuditRepository auditRepo) {
    this.userRepo = userRepo;
    this.passwordSvc = passwordSvc;
    this.policyRepo = policyRepo;
    this.auditRepo = auditRepo;
  }

  /// Create a new user.
  UserResponse createUser(CreateUserRequest req) {
    // Check username uniqueness
    if (userRepo.existsByUserName(req.tenantId, req.userName))
      return UserResponse(UserId(""), "User with this userName already exists");

    // Validate password against policy
    auto policy = policyRepo.findActiveForTenant(req.tenantId);
    if (policy != typeof(policy).init && req.password.length > 0) {
      auto validation = validatePassword(req.password, policy);
      if (!validation.valid) 
        return UserResponse(UserId(""), validation.violations.joiner("; ").to!string);
    }

    auto user = IDUser(req.tenantId);

    user.externalId = req.externalId;
    user.userName = req.userName;
    user.name = req.name;
    user.displayName = req.displayName;
    user.userType = req.userType;
    user.preferredLanguage = req.preferredLanguage;
    user.locale = req.locale;
    user.timezone = req.timezone;
    user.active = true;
    user.status = UserStatus.active;
    user.passwordHash = req.password.length > 0 ? passwordSvc.hashPassword(req.password) : "";
    user.emails = req.emails;
    user.phoneNumbers = req.phoneNumbers;
    user.addresses = req.addresses;
    user.extendedAttributes = req.extendedAttributes;
    user.schemas = req.schemas;

    userRepo.save(user);

    // Audit
    auto event = AuditEvent(req.tenantId);
    event.id = AuditEventId(createId);
    event.eventType = AuditEventType.userCreated;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = user.id.value;
    event.targetType = "User";
    event.description = "User created: " ~ req.userName;
    event.details = null;
    event.timestamp = event.createdAt;
    auditRepo.save(event);

    return UserResponse(user.id, "");
  }

  /// Get user by ID.
  IDUser getUser(TenantId tenantId, UserId id) {
    return userRepo.findById(tenantId, id);
  }

  /// List users for a tenant (SCIM paginated).
  IDUser[] listUsers(TenantId tenantId) { //}, size_t offset = 0, size_t limit = 100) {
    return userRepo.findByTenant(tenantId); //, offset, limit);
  }

  /// Search users with a SCIM-like filter.
  IDUser[] searchUsers(TenantId tenantId, string filter) { // }, size_t offset = 0, size_t limit = 100) {
    return userRepo.search(tenantId, filter); //, offset, limit);
  }

  /// Update user profile.
  string updateUser(UpdateUserRequest req) {
    auto user = userRepo.findById(req.tenantId, req.userId);
    if (user.isNull)
      return "User not found";

    if (req.name != UserName.init)
      user.name = req.name;
    if (req.displayName.length > 0)
      user.displayName = req.displayName;
    if (req.userType.length > 0)
      user.userType = req.userType;
    if (req.preferredLanguage.length > 0)
      user.preferredLanguage = req.preferredLanguage;
    if (req.locale.length > 0)
      user.locale = req.locale;
    if (req.timezone.length > 0)
      user.timezone = req.timezone;
    if (req.emails.length > 0)
      user.emails = req.emails;
    if (req.phoneNumbers.length > 0)
      user.phoneNumbers = req.phoneNumbers;
    if (req.addresses.length > 0)
      user.addresses = req.addresses;
    if (req.extendedAttributes.length > 0)
      user.extendedAttributes = req.extendedAttributes;

    user.active = req.active;
    user.status = req.active ? UserStatus.active : UserStatus.inactive;
    user.updatedAt = currentTimestamp();
    userRepo.update(user);

    auto event = AuditEvent(req.tenantId);
    event.id = AuditEventId(createId);
    event.eventType = AuditEventType.userUpdated;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = user.id.value;
    event.targetType = "User";
    event.description = "User updated: " ~ user.userName;
    event.details = null;
    event.timestamp = event.createdAt;
    auditRepo.save(event);

    return "";
  }

  /// Deactivate (soft-delete) a user.
  CommandResult deactivateUser(TenantId tenantId, UserId id) {
    auto user = userRepo.findById(tenantId, id);
    if (user.isNull)
      return CommandResult(false, "", "User not found");

    user.active = false;
    user.status = UserStatus.inactive;
    user.updatedAt = currentTimestamp();
    userRepo.update(user);

    auto event = AuditEvent(tenantId);
    event.id = AuditEventId(createId);
    event.eventType = AuditEventType.userDeactivated;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = user.id.value;
    event.targetType = "User";
    event.description = "User deactivated: " ~ user.userName;
    event.details = null;
    event.timestamp = event.createdAt;
    auditRepo.save(event);  

    return CommandResult(true, id.value, "");
  }

  /// Delete a user permanently.
  CommandResult deleteUser(TenantId tenantId, UserId id) {
    auto user = userRepo.findById(tenantId, id);
    if (user.isNull)
      return CommandResult(false, "", "User not found");

    userRepo.remove(user);

    auto event = AuditEvent(tenantId);
    event.id = AuditEventId(createId);
    event.eventType = AuditEventType.userDeleted;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = user.id.value;
    event.targetType = "User";
    event.description = "User deleted: " ~ user.userName;
    event.details = null;
    event.timestamp = event.createdAt;
    // auditRepo.save(AuditEvent(randomUUID().toString(), user.tenantId,
    //     AuditEventType.userDeleted, "system", "System", user.id, "User",
    //     "User deleted: " ~ user.userName, "", "", null, Clock.currStdTime(),));
    auditRepo.save(event);

    return CommandResult(true, user.id.value, "");
  }

  /// Change user password.
  CommandResult changePassword(TenantId tenantId, UserId id, string oldPassword, string newPassword) {
    auto user = userRepo.findById(tenantId, id);
    if (user.isNull)
      return CommandResult(false, "", "User not found");

    if (user.passwordHash.length > 0 && !passwordSvc.verifyPassword(oldPassword, user.passwordHash))
      return CommandResult(false, "", "Current password is incorrect");

    // Validate against policy
    auto policy = policyRepo.findActiveForTenant(user.tenantId);
    if (!policy.isNull) {
      auto validation = validatePassword(newPassword, policy);
      if (!validation.valid) {
        // import std.algorithm : joiner;
        
        return CommandResult(false, "", validation.violations.joiner("; ").to!string);
      }
    }

    user.passwordHash = passwordSvc.hashPassword(newPassword);
    user.updatedAt = currentTimestamp();
    userRepo.update(user);

    auto event = AuditEvent(user.tenantId);
    event.id = AuditEventId(createId);
    event.eventType = AuditEventType.passwordChanged;
    event.actorId = "system";
    // event.actorName = "System";
    event.targetId = user.id.value;
    event.targetType = "User";
    event.description = "Password changed for user: " ~ user.userName;
    event.details = null;
    event.timestamp = event.createdAt;
    auditRepo.save(event);

    return CommandResult(true, id.value, "");
  }
}
