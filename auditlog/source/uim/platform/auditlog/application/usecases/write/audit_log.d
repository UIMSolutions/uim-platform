/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.write.audit_log;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_log_entry;
import uim.platform.auditlog.domain.ports.repositories.audit_logs;
import uim.platform.auditlog.domain.ports.repositories.audit_configs;
import uim.platform.auditlog.application.dto;

@safe:
class WriteAuditLogUseCase : UIMUseCase {
  private AuditLogRepository logRepo;
  private AuditConfigRepository configRepo;

  this(AuditLogRepository logRepo, AuditConfigRepository configRepo) {
    this.logRepo = logRepo;
    this.configRepo = configRepo;
  }

  CommandResult writeLog(WriteAuditLogRequest req) {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    if (req.message.length == 0)
      return CommandResult("", "Message is required");

    // Check if logging is enabled for this tenant/category
    if (configRepo.existsByTenant(req.tenantId)) {
      auto cfg = configRepo.findByTenant(req.tenantId);
      if (cfg.status == ConfigStatus.disabled)
        return CommandResult("", "Audit logging is disabled for this tenant");

      if (req.category == AuditCategory.dataAccess && !cfg.logDataAccess)
        return CommandResult("", "Data access logging is disabled");

      if (req.category == AuditCategory.dataModification && !cfg.logDataModification)
        return CommandResult("", "Data modification logging is disabled");

      if (req.category == AuditCategory.securityEvents && !cfg.logSecurityEvents)
        return CommandResult("", "Security event logging is disabled");

      if (req.category == AuditCategory.configuration && !cfg.logConfigurationChanges)
        return CommandResult("", "Configuration change logging is disabled");
    }

    auto entry = AuditLogEntry();
    entry.id = randomUUID().toString();
    entry.tenantId = req.tenantId;
    entry.userId = req.userId;
    entry.userName = req.userName;
    entry.serviceId = req.serviceId;
    entry.serviceName = req.serviceName;
    entry.category = req.category;
    entry.severity = req.severity;
    entry.action = req.action;
    entry.outcome = req.outcome;
    entry.objectType = req.objectType;
    entry.objectId = req.objectId;
    entry.message = req.message;
    entry.attributes = req.attributes;
    entry.ipAddress = req.ipAddress;
    entry.userAgent = req.userAgent;
    entry.correlationId = req.correlationId;
    entry.originApp = req.originApp;
    entry.timestamp = Clock.currStdTime();

    logRepo.save(entry);
    return CommandResult(entry.id, "");
  }
}
