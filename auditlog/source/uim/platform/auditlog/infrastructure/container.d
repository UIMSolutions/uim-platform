module uim.platform.auditlog.infrastructure.container;

import uim.platform.auditlog.infrastructure.config;

// // Repositories
// import uim.platform.auditlog.infrastructure.persistence.memory.audit_log;
// import uim.platform.auditlog.infrastructure.persistence.memory.retention;
// import uim.platform.auditlog.infrastructure.persistence.memory.audit_config;
// import uim.platform.auditlog.infrastructure.persistence.memory.export_;
// import uim.platform.auditlog.infrastructure.persistence.memory.security_event;
// import uim.platform.auditlog.infrastructure.persistence.memory.data_access;
// import uim.platform.auditlog.infrastructure.persistence.memory.config_change;

// // Use Cases
// import uim.platform.auditlog.application.usecases.write.audit_log;
// import uim.platform.auditlog.application.usecases.retrieve_audit_logs;
// import uim.platform.auditlog.application.usecases.manage.retention;
// import uim.platform.auditlog.application.usecases.manage.audit_config;
// import uim.platform.auditlog.application.usecases.manage.exports;
// import uim.platform.auditlog.application.usecases.write.security_event;
// import uim.platform.auditlog.application.usecases.write.data_access_log;
// import uim.platform.auditlog.application.usecases.write.config_change;

// // Controllers
// import uim.platform.auditlog.presentation.http.controllers.audit_log;
// import uim.platform.auditlog.presentation.http.controllers.retention;
// import uim.platform.auditlog.presentation.http.controllers.audit_config;
// import uim.platform.auditlog.presentation.http.controllers.export_;
// import uim.platform.auditlog.presentation.http.controllers.security_event;
// import uim.platform.auditlog.presentation.http.controllers.data_access;
// import uim.platform.auditlog.presentation.http.controllers.config_change;
// import uim.platform.auditlog.presentation.http.controllers.health;

import uim.platform.auditlog;
mixin(ShowModule!());

/// Dependency injection container — wires all layers together.
@safe: struct Container
{
    // Repositories (driven adapters)
    InMemoryAuditLogRepository auditLogRepo;
    InMemoryRetentionPolicyRepository retentionRepo;
    InMemoryAuditConfigRepository auditConfigRepo;
    InMemoryExportJobRepository exportRepo;
    InMemorySecurityEventRepository securityEventRepo;
    InMemoryDataAccessLogRepository dataAccessRepo;
    InMemoryConfigChangeLogRepository configChangeRepo;

    // Use cases (application layer)
    WriteAuditLogUseCase writeAuditLog;
    RetrieveAuditLogsUseCase retrieveAuditLogs;
    ManageRetentionUseCase manageRetention;
    ManageAuditConfigUseCase manageAuditConfig;
    ManageExportsUseCase manageExports;
    WriteSecurityEventUseCase writeSecurityEvent;
    WriteDataAccessLogUseCase writeDataAccessLog;
    WriteConfigChangeUseCase writeConfigChange;

    // Controllers (driving adapters)
    AuditLogController auditLogController;
    RetentionController retentionController;
    AuditConfigController auditConfigController;
    ExportController exportController;
    SecurityEventController securityEventController;
    DataAccessController dataAccessController;
    ConfigChangeController configChangeController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.auditLogRepo = new MemoryAuditLogRepository();
    c.retentionRepo = new MemoryRetentionPolicyRepository();
    c.auditConfigRepo = new MemoryAuditConfigRepository();
    c.exportRepo = new MemoryExportJobRepository();
    c.securityEventRepo = new MemorySecurityEventRepository();
    c.dataAccessRepo = new MemoryDataAccessLogRepository();
    c.configChangeRepo = new MemoryConfigChangeLogRepository();

    // Application use cases
    c.writeAuditLog = new WriteAuditLogUseCase(c.auditLogRepo, c.auditConfigRepo);
    c.retrieveAuditLogs = new RetrieveAuditLogsUseCase(c.auditLogRepo);
    c.manageRetention = new ManageRetentionUseCase(c.retentionRepo);
    c.manageAuditConfig = new ManageAuditConfigUseCase(c.auditConfigRepo);
    c.manageExports = new ManageExportsUseCase(c.exportRepo, c.auditLogRepo);
    c.writeSecurityEvent = new WriteSecurityEventUseCase(c.auditLogRepo, c.securityEventRepo);
    c.writeDataAccessLog = new WriteDataAccessLogUseCase(c.auditLogRepo, c.dataAccessRepo);
    c.writeConfigChange = new WriteConfigChangeUseCase(c.auditLogRepo, c.configChangeRepo);

    // Presentation controllers
    c.auditLogController = new AuditLogController(c.writeAuditLog, c.retrieveAuditLogs);
    c.retentionController = new RetentionController(c.manageRetention);
    c.auditConfigController = new AuditConfigController(c.manageAuditConfig);
    c.exportController = new ExportController(c.manageExports);
    c.securityEventController = new SecurityEventController(c.writeSecurityEvent);
    c.dataAccessController = new DataAccessController(c.writeDataAccessLog);
    c.configChangeController = new ConfigChangeController(c.writeConfigChange);
    c.healthController = new HealthController("auditlog");

    return c;
}
