module application.usecases.write_config_change;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.audit_log_entry;
import domain.entities.config_change_log;
import domain.ports.audit_log_repository;
import domain.ports.config_change_log_repository;
import application.dto;

class WriteConfigChangeUseCase
{
    private AuditLogRepository auditRepo;
    private ConfigChangeLogRepository cclRepo;

    this(AuditLogRepository auditRepo, ConfigChangeLogRepository cclRepo)
    {
        this.auditRepo = auditRepo;
        this.cclRepo = cclRepo;
    }

    CommandResult writeChange(WriteConfigChangeLogRequest req)
    {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.configType.length == 0)
            return CommandResult("", "Config type is required");

        auto now = Clock.currStdTime();
        auto auditId = randomUUID().toString();

        // Create parent audit log entry
        auto entry = AuditLogEntry();
        entry.id = auditId;
        entry.tenantId = req.tenantId;
        entry.userId = req.changedBy;
        entry.category = AuditCategory.configuration;
        entry.severity = AuditSeverity.info;
        entry.action = AuditAction.configChange;
        entry.outcome = AuditOutcome.success;
        entry.objectType = req.configType;
        entry.objectId = req.configObjectId;
        entry.message = "Configuration change: " ~ req.configType
            ~ " / " ~ req.configObjectId ~ " by " ~ req.changedBy;
        entry.attributes = req.changes;
        entry.timestamp = now;
        auditRepo.save(entry);

        // Create config change record
        auto ccl = ConfigChangeLog();
        ccl.auditLogId = auditId;
        ccl.tenantId = req.tenantId;
        ccl.changedBy = req.changedBy;
        ccl.configType = req.configType;
        ccl.configObjectId = req.configObjectId;
        ccl.changes = req.changes;
        ccl.reason = req.reason;
        ccl.timestamp = now;
        cclRepo.save(ccl);

        return CommandResult(auditId, "");
    }
}
