/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.services.retention_enforcer;

// import uim.platform.auditlog.domain.ports.repositories.audit_logs;
// import uim.platform.auditlog.domain.ports.repositories.retention_policys;
// import uim.platform.auditlog.domain.ports.repositories.security_events;
// import uim.platform.auditlog.domain.ports.repositories.data_access_logs;
// import uim.platform.auditlog.domain.ports.repositories.config_change_logs;

import uim.platform.auditlog;

mixin(ShowModule!());
/// Domain service — enforces retention policies by purging expired entries.
@safe:
class RetentionEnforcer {
  private IAuditLogRepository auditRepo;
  private RetentionPolicyRepository policyRepo;
  private SecurityEventRepository secRepo;
  private DataAccessLogRepository dalRepo;
  private IConfigChangeLogRepository cclRepo;

  this(IAuditLogRepository auditRepo, RetentionPolicyRepository policyRepo,
      SecurityEventRepository secRepo, DataAccessLogRepository dalRepo,
      IConfigChangeLogRepository cclRepo) {
    this.auditRepo = auditRepo;
    this.policyRepo = policyRepo;
    this.secRepo = secRepo;
    this.dalRepo = dalRepo;
    this.cclRepo = cclRepo;
  }

  /// Purge logs older than the tenant's retention policy allows.
  long enforceForTenant(TenantId tenantId) {
  

    auto policy = policyRepo.findDefault(tenantId);
    int days = 90; // SAP default
    if (policyRepo.existsDefault(tenantId) && policy.retentionDays > 0)
      days = policy.retentionDays;

    // Convert days to hnsecs cutoff
    auto now = currentTimestamp();
    long cutoff = now - (days * 24 * 60 * 60 * 10_000_000L);

    auditRepo.removeOlderThan(tenantId, cutoff);
    secRepo.removeOlderThan(tenantId, cutoff);
    dalRepo.removeOlderThan(tenantId, cutoff);
    cclRepo.removeOlderThan(tenantId, cutoff);

    return cutoff;
  }
}
