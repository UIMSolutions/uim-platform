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

// import std.uuid;
// import std.datetime.systime : Clock;
import uim.platform.identity.directory;

mixin(ShowModule!());

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
    auto now = Clock.currStdTime();
    auto policyId = randomUUID();
    auto policy = PasswordPolicy(policyId, req.tenantId, req.name, req.description,
        PasswordStrength.standard, req.minLength > 0 ? req.minLength : 8,
        req.maxLength > 0 ? req.maxLength : 128, req.requireUppercase, req.requireLowercase,
        req.requireDigit, req.requireSpecialChar, req.minUniqueChars, req.maxRepeatedChars,
        req.passwordHistoryCount, req.maxFailedAttempts > 0 ? req.maxFailedAttempts : 5,
        req.lockoutDurationMinutes > 0 ? req.lockoutDurationMinutes : 30,
        req.expiryDays, 14, // warningDaysBeforeExpiry
        true, now, now,);
    policyRepo.save(policy);

    auditRepo.save(AuditEvent(randomUUID().toString(), req.tenantId, AuditEventType.schemaCreated, // reuse event type
        "system", "System", policyId, "PasswordPolicy",
        "Password policy created: " ~ req.name, "", "", null, now,));

    return PasswordPolicyResponse(policyId, "");
  }

  /// Get policy by ID.
  PasswordPolicy getPolicy(string id) {
    return policyRepo.findById(id);
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
