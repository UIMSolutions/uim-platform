module application.usecases.write_data_access_log;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_log_entry;
import uim.platform.auditlog.domain.entities.data_access_log;
import uim.platform.auditlog.domain.ports.audit_log_repository;
import uim.platform.auditlog.domain.ports.data_access_log_repository;
import application.dto;

class WriteDataAccessLogUseCase
{
    private AuditLogRepository auditRepo;
    private DataAccessLogRepository dalRepo;

    this(AuditLogRepository auditRepo, DataAccessLogRepository dalRepo)
    {
        this.auditRepo = auditRepo;
        this.dalRepo = dalRepo;
    }

    CommandResult writeLog(WriteDataAccessLogRequest req)
    {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.dataSubject.length == 0)
            return CommandResult("", "Data subject is required");

        auto now = Clock.currStdTime();
        auto auditId = randomUUID().toString();

        // Create parent audit log entry
        auto entry = AuditLogEntry();
        entry.id = auditId;
        entry.tenantId = req.tenantId;
        entry.userId = req.accessedBy;
        entry.category = AuditCategory.dataAccess;
        entry.severity = AuditSeverity.info;
        entry.action = AuditAction.dataAccess;
        entry.outcome = AuditOutcome.success;
        entry.objectType = req.dataObjectType;
        entry.objectId = req.dataObjectId;
        entry.message = "Data access: " ~ req.dataObjectType ~ " / " ~ req.dataObjectId
            ~ " by " ~ req.accessedBy ~ " purpose=" ~ req.purpose;
        entry.timestamp = now;
        auditRepo.save(entry);

        // Create data access record
        auto dal = DataAccessLog();
        dal.auditLogId = auditId;
        dal.tenantId = req.tenantId;
        dal.accessedBy = req.accessedBy;
        dal.dataSubject = req.dataSubject;
        dal.dataObjectType = req.dataObjectType;
        dal.dataObjectId = req.dataObjectId;
        dal.accessedFields = req.accessedFields;
        dal.purpose = req.purpose;
        dal.channel = req.channel;
        dal.timestamp = now;
        dalRepo.save(dal);

        return CommandResult(auditId, "");
    }
}
