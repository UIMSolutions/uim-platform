/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.write.config_change;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;
// import uim.platform.auditlog.domain.entities.config_change_log;
// import uim.platform.auditlog.domain.ports.repositories.audit_logs;
// import uim.platform.auditlog.domain.ports.repositories.config_change_logs;
// import uim.platform.auditlog.application.dto;

import uim.platform.auditlog; 

mixin(ShowModule!());

@safe:
class WriteConfigChangeUseCase { // TODO: UIMUseCase {
  private AuditLogRepository auditRepo;
  private ConfigChangeLogRepository cclRepo;

  this(AuditLogRepository auditRepo, ConfigChangeLogRepository cclRepo) {
    this.auditRepo = auditRepo;
    this.cclRepo = cclRepo;
  }

  CommandResult writeChange(WriteConfigChangeLogRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.configType.length == 0)
      return CommandResult(false, "", "Config type is required");

    // Create parent audit log entry
    auto entry = AuditLogEntry();
    entry.id = randomUUID();
    entry.tenantId = req.tenantId;
    entry.userId = req.changedBy;
    entry.category = AuditCategory.configuration;
    entry.severity = AuditSeverity.info;
    entry.action = AuditAction.configChange;
    entry.outcome = AuditOutcome.success;
    entry.objectType = req.configType;
    entry.objectId = req.configObjectId;
    entry.message = "Configuration change: %s / %s by %s".format(req.configType, req.configObjectId, req.changedBy);
    entry.attributes = req.changes;
    entry.timestamp = Clock.currStdTime();
    auditRepo.save(entry);

    // Create config change record
    auto ccLog = ConfigChangeLog();
    ccLog.id = entry.id;
    ccLog.tenantId = req.tenantId;
    ccLog.changedBy = req.changedBy;
    ccLog.configType = req.configType;
    ccLog.configObjectId = req.configObjectId;
    ccLog.changes = req.changes;
    ccLog.reason = req.reason;
    ccLog.timestamp = entry.timestamp;
    cclRepo.save(ccLog);

    return CommandResult(true, entry.id.toString(), "");
  }
}
