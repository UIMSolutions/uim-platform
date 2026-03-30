module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_audit_log_repo;
import infrastructure.persistence.in_memory_retention_repo;
import infrastructure.persistence.in_memory_audit_config_repo;
import infrastructure.persistence.in_memory_export_repo;
import infrastructure.persistence.in_memory_security_event_repo;
import infrastructure.persistence.in_memory_data_access_repo;
import infrastructure.persistence.in_memory_config_change_repo;

// Use Cases
import application.use_cases.write_audit_log;
import application.use_cases.retrieve_audit_logs;
import application.use_cases.manage_retention;
import application.use_cases.manage_audit_config;
import application.use_cases.manage_exports;
import application.use_cases.write_security_event;
import application.use_cases.write_data_access_log;
import application.use_cases.write_config_change;

// Controllers
import uim.platform.identity_authentication.presentation.http.audit_log_controller;
import uim.platform.identity_authentication.presentation.http.retention_controller;
import uim.platform.identity_authentication.presentation.http.audit_config_controller;
import uim.platform.identity_authentication.presentation.http.export_controller;
import uim.platform.identity_authentication.presentation.http.security_event_controller;
import uim.platform.identity_authentication.presentation.http.data_access_controller;
import uim.platform.identity_authentication.presentation.http.config_change_controller;
import uim.platform.identity_authentication.presentation.http.health_controller;

/// Dependency injection container — wires all layers together.
struct Container
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
    c.auditLogRepo = new InMemoryAuditLogRepository();
    c.retentionRepo = new InMemoryRetentionPolicyRepository();
    c.auditConfigRepo = new InMemoryAuditConfigRepository();
    c.exportRepo = new InMemoryExportJobRepository();
    c.securityEventRepo = new InMemorySecurityEventRepository();
    c.dataAccessRepo = new InMemoryDataAccessLogRepository();
    c.configChangeRepo = new InMemoryConfigChangeLogRepository();

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
    c.healthController = new HealthController();

    return c;
}
