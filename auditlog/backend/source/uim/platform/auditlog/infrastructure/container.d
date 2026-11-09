/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.container;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (HTTP, OData, CLI, GUI) are created by the entry points
/// (app.d, cli.d, gui.d) on top of this container and only see the port interfaces.
class Container {
  AuditLogConfig config;

  // ── Driven adapters (persistence) ─────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  AuditLogRepository auditLogRepo;
  RetentionPolicyRepository retentionRepo;
  AuditConfigRepository auditConfigRepo;
  ExportJobRepository exportRepo;
  SecurityEventRepository securityEventRepo;
  DataAccessLogRepository dataAccessRepo;
  ConfigChangeLogRepository configChangeRepo;
  IAuditEventPublisher publisher;

  // ── Domain services ───────────────────────────────────────────────────
  RetentionEnforcer retentionEnforcer;

  // ── Driving ports (use cases & application services) ──────────────────
  IWriteAuditLogUseCase writeAuditLog;
  IRetrieveAuditLogsUseCase retrieveAuditLogs;
  IBrowseAuditRecordsUseCase browseRecords;
  IManageRetentionUseCase manageRetention;
  IEnforceRetentionUseCase enforceRetention;
  IManageAuditConfigUseCase manageAuditConfig;
  IManageExportsUseCase manageExports;
  IWriteSecurityEventUseCase writeSecurityEvent;
  IWriteDataAccessLogUseCase writeDataAccessLog;
  IWriteConfigChangeUseCase writeConfigChange;
  IAuditStatisticsService statistics;

  /// The driving ports for presentation adapters.
  AuditLogPorts ports() {
    AuditLogPorts p;
    p.writeAuditLog = writeAuditLog;
    p.retrieveAuditLogs = retrieveAuditLogs;
    p.browseRecords = browseRecords;
    p.writeSecurityEvent = writeSecurityEvent;
    p.writeDataAccessLog = writeDataAccessLog;
    p.writeConfigChange = writeConfigChange;
    p.manageRetention = manageRetention;
    p.enforceRetention = enforceRetention;
    p.manageAuditConfig = manageAuditConfig;
    p.manageExports = manageExports;
    p.statistics = statistics;
    return p;
  }

  this(AuditLogConfig config) {
    this.config = config;
    wirePersistence();
    wireApplication();
  }

  protected void wirePersistence() {
    if (config.usesFileStorage) {
      storage = new JsonFileSnapshotStorage(config.dataDir);
      auditLogRepo = new AuditLogRepository(
        new SnapshotTenantStore!(AuditLogEntry, AuditLogId, AuditLogEntryMapper)(storage, AuditCollections.auditLogs));
      retentionRepo = new RetentionPolicyRepository(
        new SnapshotTenantStore!(RetentionPolicy, RetentionPolicyId, RetentionPolicyMapper)(storage, AuditCollections.retentionPolicies));
      auditConfigRepo = new AuditConfigRepository(
        new SnapshotTenantStore!(AuditConfig, AuditConfigId, AuditConfigMapper)(storage, AuditCollections.auditConfigs));
      exportRepo = new ExportJobRepository(
        new SnapshotTenantStore!(ExportJob, ExportJobId, ExportJobMapper)(storage, AuditCollections.exportJobs));
      securityEventRepo = new SecurityEventRepository(
        new SnapshotTenantStore!(SecurityEvent, SecurityEventId, SecurityEventMapper)(storage, AuditCollections.securityEvents));
      dataAccessRepo = new DataAccessLogRepository(
        new SnapshotTenantStore!(DataAccessLog, DataAccessLogId, DataAccessLogMapper)(storage, AuditCollections.dataAccessLogs));
      configChangeRepo = new ConfigChangeLogRepository(
        new SnapshotTenantStore!(ConfigChangeLog, ConfigChangeLogId, ConfigChangeLogMapper)(storage, AuditCollections.configChangeLogs));
    } else {
      auditLogRepo = new AuditLogRepository();
      retentionRepo = new RetentionPolicyRepository();
      auditConfigRepo = new AuditConfigRepository();
      exportRepo = new ExportJobRepository();
      securityEventRepo = new SecurityEventRepository();
      dataAccessRepo = new DataAccessLogRepository();
      configChangeRepo = new ConfigChangeLogRepository();
    }
    publisher = new LogEventPublisher();
  }

  protected void wireApplication() {
    retentionEnforcer = new RetentionEnforcer(auditLogRepo, retentionRepo,
      securityEventRepo, dataAccessRepo, configChangeRepo);

    writeAuditLog = new WriteAuditLogUseCase(auditLogRepo, auditConfigRepo, publisher);
    retrieveAuditLogs = new RetrieveAuditLogsUseCase(auditLogRepo);
    browseRecords = new BrowseAuditRecordsUseCase(securityEventRepo, dataAccessRepo, configChangeRepo);
    manageRetention = new ManageRetentionUseCase(retentionRepo);
    enforceRetention = new EnforceRetentionUseCase(retentionEnforcer, publisher);
    manageAuditConfig = new ManageAuditConfigUseCase(auditConfigRepo);
    manageExports = new ManageExportsUseCase(exportRepo, auditLogRepo, publisher);
    writeSecurityEvent = new WriteSecurityEventUseCase(auditLogRepo, securityEventRepo, auditConfigRepo);
    writeDataAccessLog = new WriteDataAccessLogUseCase(auditLogRepo, dataAccessRepo, auditConfigRepo);
    writeConfigChange = new WriteConfigChangeUseCase(auditLogRepo, configChangeRepo, auditConfigRepo);
    statistics = new AuditStatisticsService(auditLogRepo, securityEventRepo, dataAccessRepo,
      configChangeRepo, retentionRepo, exportRepo, retentionEnforcer);
  }
}

/// Build the full dependency graph.
Container buildContainer(AuditLogConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container"));

  AuditLogConfig cfg;
  cfg.storage = "memory";
  auto c = buildContainer(cfg);
  assert(c.storage is null);

  WriteAuditLogRequest req;
  req.tenantId = TenantId("t1");
  req.message = "hello";
  assert(c.writeAuditLog.writeAuditLog(req).isSuccess);
  assert(c.statistics.statistics(TenantId("t1")).totalEntries == 1);
}
