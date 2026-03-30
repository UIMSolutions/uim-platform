module domain.services.retention_enforcer;

import domain.types;
import domain.ports.audit_log_repository;
import domain.ports.retention_policy_repository;
import domain.ports.security_event_repository;
import domain.ports.data_access_log_repository;
import domain.ports.config_change_log_repository;

/// Domain service — enforces retention policies by purging expired entries.
class RetentionEnforcer
{
    private AuditLogRepository auditRepo;
    private RetentionPolicyRepository policyRepo;
    private SecurityEventRepository secRepo;
    private DataAccessLogRepository dalRepo;
    private ConfigChangeLogRepository cclRepo;

    this(AuditLogRepository auditRepo,
        RetentionPolicyRepository policyRepo,
        SecurityEventRepository secRepo,
        DataAccessLogRepository dalRepo,
        ConfigChangeLogRepository cclRepo)
    {
        this.auditRepo = auditRepo;
        this.policyRepo = policyRepo;
        this.secRepo = secRepo;
        this.dalRepo = dalRepo;
        this.cclRepo = cclRepo;
    }

    /// Purge logs older than the tenant's retention policy allows.
    long enforceForTenant(TenantId tenantId)
    {
        import std.datetime.systime : Clock;

        auto policy = policyRepo.findDefault(tenantId);
        int days = 90; // SAP default
        if (policy !is null && policy.retentionDays > 0)
            days = policy.retentionDays;

        // Convert days to hnsecs cutoff
        auto now = Clock.currStdTime();
        long cutoff = now - (cast(long) days * 24 * 60 * 60 * 10_000_000L);

        auditRepo.removeOlderThan(tenantId, cutoff);
        secRepo.removeOlderThan(tenantId, cutoff);
        dalRepo.removeOlderThan(tenantId, cutoff);
        cclRepo.removeOlderThan(tenantId, cutoff);

        return cutoff;
    }
}
