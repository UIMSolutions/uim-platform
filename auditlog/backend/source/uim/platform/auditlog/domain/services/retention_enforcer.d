/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.services.retention_enforcer;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Result of one retention run.
struct RetentionOutcome {
  long cutoff; /// stdTime; records older than this were removed
  int retentionDays; /// effective retention period
  size_t removed; /// number of removed records over all log types
}

/// Domain service — enforces retention policies by purging expired entries.
class RetentionEnforcer {
  enum int defaultRetentionDays = 90; // SAP default
  enum long hnsecsPerDay = 24L * 60 * 60 * 10_000_000L;

  protected IAuditLogRepository auditRepo;
  protected IRetentionPolicyRepository policyRepo;
  protected ISecurityEventRepository secRepo;
  protected IDataAccessLogRepository dalRepo;
  protected IConfigChangeLogRepository cclRepo;

  this(IAuditLogRepository auditRepo, IRetentionPolicyRepository policyRepo,
      ISecurityEventRepository secRepo, IDataAccessLogRepository dalRepo,
      IConfigChangeLogRepository cclRepo) {
    this.auditRepo = auditRepo;
    this.policyRepo = policyRepo;
    this.secRepo = secRepo;
    this.dalRepo = dalRepo;
    this.cclRepo = cclRepo;
  }

  /// Effective retention days of a tenant (active default policy or SAP default).
  int retentionDaysFor(TenantId tenantId) {
    if (policyRepo.existsDefault(tenantId)) {
      auto policy = policyRepo.findDefault(tenantId);
      if (policy.retentionDays > 0)
        return policy.retentionDays;
    }
    return defaultRetentionDays;
  }

  /// Purge logs older than the tenant's retention policy allows.
  RetentionOutcome enforceForTenant(TenantId tenantId) {
    RetentionOutcome outcome;
    outcome.retentionDays = retentionDaysFor(tenantId);
    outcome.cutoff = currentTimestamp() - outcome.retentionDays * hnsecsPerDay;

    auto before = total(tenantId);
    auditRepo.removeOlderThan(tenantId, outcome.cutoff);
    secRepo.removeOlderThan(tenantId, outcome.cutoff);
    dalRepo.removeOlderThan(tenantId, outcome.cutoff);
    cclRepo.removeOlderThan(tenantId, outcome.cutoff);
    outcome.removed = before - total(tenantId);

    return outcome;
  }

  private size_t total(TenantId tenantId) {
    return auditRepo.countByTenant(tenantId) + secRepo.countByTenant(tenantId)
      + dalRepo.countByTenant(tenantId) + cclRepo.countByTenant(tenantId);
  }
}
///
unittest {
  mixin(ShowTest!("RetentionEnforcer"));

  auto logs = new AuditLogRepository();
  auto policies = new RetentionPolicyRepository();
  auto enforcer = new RetentionEnforcer(logs, policies, new SecurityEventRepository(),
    new DataAccessLogRepository(), new ConfigChangeLogRepository());
  auto tenant = TenantId("t1");

  auto old = AuditLogEntry(tenant);
  old.timestamp = currentTimestamp() - 100 * RetentionEnforcer.hnsecsPerDay;
  logs.save(old);
  auto fresh = AuditLogEntry(tenant);
  fresh.timestamp = currentTimestamp();
  logs.save(fresh);

  assert(enforcer.retentionDaysFor(tenant) == 90);
  auto outcome = enforcer.enforceForTenant(tenant);
  assert(outcome.removed == 1);
  assert(logs.countByTenant(tenant) == 1);
}
