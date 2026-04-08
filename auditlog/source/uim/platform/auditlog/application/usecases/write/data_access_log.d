/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.write.data_access_log;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;
// import uim.platform.auditlog.domain.entities.data_access_log;
// import uim.platform.auditlog.domain.ports.repositories.audit_logs;
// import uim.platform.auditlog.domain.ports.repositories.data_access_logs;
// import uim.platform.auditlog.application.dto;

import uim.platform.auditlog; 

mixin(ShowModule!());

@safe:
class WriteDataAccessLogUseCase : UIMUseCase {
  private AuditLogRepository auditRepo;
  private DataAccessLogRepository dalRepo;

  this(AuditLogRepository auditRepo, DataAccessLogRepository dalRepo) {
    this.auditRepo = auditRepo;
    this.dalRepo = dalRepo;
  }

  CommandResult writeLog(WriteDataAccessLogRequest req) {
    if (req.tenantId.isEmpty)
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
    entry.message = "Data access: %s / %s by %s purpose=%s".format(req.dataObjectType, req.dataObjectId, req.accessedBy, req.purpose);
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
