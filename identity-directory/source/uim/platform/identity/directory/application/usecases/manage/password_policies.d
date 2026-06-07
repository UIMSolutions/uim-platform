/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.application.usecases.manage.password_policies;
// import uim.platform.identity.directory.domain.entities.password_policy;
// import uim.platform.identity.directory.domain.entities.audit_event;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.password_policys;
// import uim.platform.identity.directory.domain.ports.repositories.audits;
// import uim.platform.identity.directory.application.dto;


import uim.platform.identity.directory;

// mixin(ShowModule!());

@safe:
/// Application use case: password policy management.
class ManagePasswordPoliciesUseCase { // TODO: UIMUseCase {
  private PasswordPolicyRepository policyRepo;
  private AuditRepository auditRepo;

  this(PasswordPolicyRepository policyRepo, AuditRepository auditRepo) {
    this.policyRepo = policyRepo;
    this.auditRepo = auditRepo;
  }

  /// Create a new password policy.
  PasswordPolicyResponse createPolicy(CreatePasswordPolicyRequest req) {
    PasswordPolicy policy;
    policy.initEntity(req.tenantId);

    policy.name = req.name;
    policy.description = req.description;
    policy.strength = PasswordStrength.standard;
    policy.minLength = req.minLength > 0 ? req.minLength : 8;
    policy.maxLength = req.maxLength > 0 ? req.maxLength : 128;
    policy.requireUppercase = req.requireUppercase;
    policy.requireLowercase = req.requireLowercase;
    policy.requireDigit = req.requireDigit;
    policy.requireSpecialChar = req.requireSpecialChar;
    policy.minUniqueChars = req.minUniqueChars;
    policy.maxRepeatedChars = req.maxRepeatedChars;
    policy.passwordHistoryCount = req.passwordHistoryCount;
    policy.maxFailedAttempts = req.maxFailedAttempts > 0 ? req.maxFailedAttempts : 5;
    policy.lockoutDurationMinutes = req.lockoutDurationMinutes > 0 ? req.lockoutDurationMinutes : 30;
    policy.expiryDays = req.expiryDays > 0 ? req.expiryDays : 90;
    policy.warningDaysBeforeExpiry = 14;
    policy.isActive = true;

    policyRepo.save(policy);

    AuditEvent event;
    event.initEntity(req.tenantId);

    event.eventType = AuditEventType.schemaCreated; // reuse event type
    event.actorId = req.createdBy;
    event.actorName = req.createdBy; // TODO: lookup user name
    event.targetId = policy.id.value;
    event.targetType = "PasswordPolicy";
    event.description = "Password policy created: " ~ req.name;

    auditRepo.save(event);  

    return PasswordPolicyResponse(policyId, "");
  }

  /// Get policy by ID.
  PasswordPolicy getPolicy(string id) {
    return policyRepo.findById(tenantId, id);
  }

  /// List policies for a tenant.
  PasswordPolicy[] listPolicies(TenantId tenantId) {
    return policyRepo.findByTenant(tenantId);
  }

  /// Get active policy for tenant.
  PasswordPolicy getActivePolicy(TenantId tenantId) {
    return policyRepo.findActiveForTenant(tenantId);
  }
}
