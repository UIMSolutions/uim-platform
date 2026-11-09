/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.services.statistics;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Application service: aggregated audit figures for dashboards.
class AuditStatisticsService : IAuditStatisticsService {
  protected IAuditLogRepository auditLogs;
  protected ISecurityEventRepository securityEvents;
  protected IDataAccessLogRepository dataAccessLogs;
  protected IConfigChangeLogRepository configChanges;
  protected IRetentionPolicyRepository retentionPolicies;
  protected IExportJobRepository exportJobs;
  protected RetentionEnforcer enforcer;

  this(IAuditLogRepository auditLogs, ISecurityEventRepository securityEvents,
      IDataAccessLogRepository dataAccessLogs, IConfigChangeLogRepository configChanges,
      IRetentionPolicyRepository retentionPolicies, IExportJobRepository exportJobs,
      RetentionEnforcer enforcer) {
    this.auditLogs = auditLogs;
    this.securityEvents = securityEvents;
    this.dataAccessLogs = dataAccessLogs;
    this.configChanges = configChanges;
    this.retentionPolicies = retentionPolicies;
    this.exportJobs = exportJobs;
    this.enforcer = enforcer;
  }

  AuditStatistics statistics(TenantId tenantId) {
    AuditStatistics s;
    s.tenantId = tenantId;

    foreach (c; [EnumMembers!AuditCategory])
      s.byCategory[c.to!string] = 0;
    foreach (v; [EnumMembers!AuditSeverity])
      s.bySeverity[v.to!string] = 0;
    foreach (o; [EnumMembers!AuditOutcome])
      s.byOutcome[o.to!string] = 0;

    foreach (e; auditLogs.findByTenant(tenantId)) {
      s.totalEntries++;
      s.byCategory[e.category.to!string]++;
      s.bySeverity[e.severity.to!string]++;
      s.byOutcome[e.outcome.to!string]++;
      if (e.timestamp > s.lastEntryAt)
        s.lastEntryAt = e.timestamp;
    }

    auto events = securityEvents.findByTenant(tenantId);
    s.securityEvents = events.length;
    s.failedLogins = events.count!(e => e.outcome != AuditOutcome.success);
    s.dataAccessLogs = dataAccessLogs.countByTenant(tenantId);
    s.configChanges = configChanges.countByTenant(tenantId);
    s.retentionPolicies = retentionPolicies.countByTenant(tenantId);
    s.exportJobs = exportJobs.countByTenant(tenantId);
    s.retentionDays = enforcer.retentionDaysFor(tenantId);
    return s;
  }
}
