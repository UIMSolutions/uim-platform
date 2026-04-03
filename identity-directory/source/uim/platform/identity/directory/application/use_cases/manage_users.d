module uim.platform.identity.directory.application.usecases.manage_users;

import uim.platform.identity.directory.domain.entities.user;
import uim.platform.identity.directory.domain.entities.audit_event;
import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory.domain.ports.user_repository;
import uim.platform.identity.directory.domain.ports.password_service;
import uim.platform.identity.directory.domain.ports.password_policy_repository;
import uim.platform.identity.directory.domain.ports.audit_repository;
import uim.platform.identity.directory.domain.services.password_validator;
import uim.platform.identity.directory.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;

/// Application use case: SCIM 2.0 user management (CRUD + search).
class ManageUsersUseCase
{
  private UserRepository userRepo;
  private PasswordService passwordSvc;
  private PasswordPolicyRepository policyRepo;
  private AuditRepository auditRepo;

  this(UserRepository userRepo, PasswordService passwordSvc,
      PasswordPolicyRepository policyRepo, AuditRepository auditRepo)
  {
    this.userRepo = userRepo;
    this.passwordSvc = passwordSvc;
    this.policyRepo = policyRepo;
    this.auditRepo = auditRepo;
  }

  /// Create a new user.
  UserResponse createUser(CreateUserRequest req)
  {
    // Check username uniqueness
    auto existing = userRepo.findByUserName(req.tenantId, req.userName);
    if (existing != User.init)
      return UserResponse("", "User with this userName already exists");

    // Validate password against policy
    auto policy = policyRepo.findActiveForTenant(req.tenantId);
    if (policy != typeof(policy).init && req.password.length > 0)
    {
      auto validation = validatePassword(req.password, policy);
      if (!validation.valid)
      {
        // import std.algorithm : joiner;
        // import std.conv : to;
        return UserResponse("", validation.violations.joiner("; ").to!string);
      }
    }

    auto now = Clock.currStdTime();
    auto userId = randomUUID().toString();
    auto user = User(userId, req.tenantId, req.externalId, req.userName,
        req.name, req.displayName, "", // nickName
        "", // profileUrl
        req.userType, "", // title
        req.preferredLanguage, req.locale, req.timezone, true, // active
        UserStatus.active,
        req.password.length > 0 ? passwordSvc.hashPassword(req.password) : "",
        req.emails, req.phoneNumbers, req.addresses, [], // groupIds
        req.extendedAttributes,
        req.schemas, now, now,);
    userRepo.save(user);

    // Audit
    auditRepo.save(AuditEvent(randomUUID().toString(), req.tenantId,
        AuditEventType.userCreated, "system", "System", userId, "User",
        "User created: " ~ req.userName, "", "", null, now,));

    return UserResponse(userId, "");
  }

  /// Get user by ID.
  User getUser(UserId id)
  {
    return userRepo.findById(id);
  }

  /// List users for a tenant (SCIM paginated).
  User[] listUsers(TenantId tenantId, uint offset = 0, uint limit = 100)
  {
    return userRepo.findByTenant(tenantId, offset, limit);
  }

  /// Search users with a SCIM-like filter.
  User[] searchUsers(TenantId tenantId, string filter, uint offset = 0, uint limit = 100)
  {
    return userRepo.search(tenantId, filter, offset, limit);
  }

  /// Update user profile.
  string updateUser(UpdateUserRequest req)
  {
    auto user = userRepo.findById(req.userId);
    if (user == User.init)
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
    user.updatedAt = Clock.currStdTime();
    userRepo.update(user);

    auditRepo.save(AuditEvent(randomUUID().toString(), user.tenantId,
        AuditEventType.userUpdated, "system", "System", req.userId, "User",
        "User updated", "", "", null, Clock.currStdTime(),));

    return "";
  }

  /// Deactivate (soft-delete) a user.
  string deactivateUser(UserId id)
  {
    auto user = userRepo.findById(id);
    if (user == User.init)
      return "User not found";

    user.active = false;
    user.status = UserStatus.inactive;
    user.updatedAt = Clock.currStdTime();
    userRepo.update(user);

    auditRepo.save(AuditEvent(randomUUID().toString(), user.tenantId,
        AuditEventType.userDeactivated, "system", "System", id, "User",
        "User deactivated", "", "", null, Clock.currStdTime(),));

    return "";
  }

  /// Delete a user permanently.
  string deleteUser(UserId id)
  {
    auto user = userRepo.findById(id);
    if (user == User.init)
      return "User not found";

    userRepo.remove(id);

    auditRepo.save(AuditEvent(randomUUID().toString(), user.tenantId,
        AuditEventType.userDeleted, "system", "System", id, "User",
        "User deleted: " ~ user.userName, "", "", null, Clock.currStdTime(),));

    return "";
  }

  /// Change user password.
  string changePassword(UserId id, string oldPassword, string newPassword)
  {
    auto user = userRepo.findById(id);
    if (user == User.init)
      return "User not found";

    if (user.passwordHash.length > 0 && !passwordSvc.verifyPassword(oldPassword, user.passwordHash))
      return "Current password is incorrect";

    // Validate against policy
    auto policy = policyRepo.findActiveForTenant(user.tenantId);
    if (policy != typeof(policy).init)
    {
      auto validation = validatePassword(newPassword, policy);
      if (!validation.valid)
      {
        // import std.algorithm : joiner;
        // import std.conv : to;
        return validation.violations.joiner("; ").to!string;
      }
    }

    user.passwordHash = passwordSvc.hashPassword(newPassword);
    user.updatedAt = Clock.currStdTime();
    userRepo.update(user);

    auditRepo.save(AuditEvent(randomUUID().toString(), user.tenantId,
        AuditEventType.passwordChanged, id, "User", id, "User",
        "Password changed", "", "", null, Clock.currStdTime(),));

    return "";
  }
}
