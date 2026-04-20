/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.write.security_event;

// // import std.uuid;
// // import std.datetime.systime : Clock;
// 
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.audit_log_entry;
// import uim.platform.auditlog.domain.entities.security_event;
// import uim.platform.auditlog.domain.ports.repositories.audit_logs;
// import uim.platform.auditlog.domain.ports.repositories.security_events;
// import uim.platform.auditlog.application.dto;

import uim.platform.auditlog;

mixin(ShowModule!());
@safe:
class WriteSecurityEventUseCase { // TODO: UIMUseCase {
  private AuditLogRepository auditRepo;
  private SecurityEventRepository secRepo;

  this(AuditLogRepository auditRepo, SecurityEventRepository secRepo) {
    this.auditRepo = auditRepo;
    this.secRepo = secRepo;
  }

  CommandResult writeEvent(WriteSecurityEventRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    if (req.eventType.length == 0)
      return CommandResult(false, "", "Event type is required");

    // Create parent audit log entry
    auto entry = AuditLogEntry();
    entry.id = randomUUID();
    entry.tenantId = req.tenantId;
    entry.userId = req.userId;
    entry.userName = req.userName;
    entry.category = AuditCategory.securityEvents;
    entry.severity = req.outcome == AuditOutcome.failure ? AuditSeverity.warning
      : AuditSeverity.info;
    entry.action = req.eventType.to!AuditAction;
    entry.outcome = req.outcome;
    entry.message = buildSecurityMessage(req);
    entry.ipAddress = req.ipAddress;
    entry.userAgent = req.userAgent;
    entry.timestamp = Clock.currStdTime();
    auditRepo.save(entry);

    // Create enriched security event
    auto secEvent = SecurityEvent();
    secEvent.auditLogId = entry.id;
    secEvent.tenantId = req.tenantId;
    secEvent.userId = req.userId;
    secEvent.userName = req.userName;
    secEvent.eventType = req.eventType;
    secEvent.ipAddress = req.ipAddress;
    secEvent.userAgent = req.userAgent;
    secEvent.clientId = req.clientId;
    secEvent.identityProvider = req.identityProvider;
    secEvent.authMethod = req.authMethod;
    secEvent.outcome = req.outcome;
    secEvent.failureReason = req.failureReason;
    secEvent.riskLevel = req.riskLevel;
    secEvent.timestamp = entry.timestamp;
    secRepo.save(secEvent);

    return CommandResult(true, entry.id.toString(), "");
  }

  private string buildSecurityMessage(WriteSecurityEventRequest req) {
    // import std.conv : to;

    return req.eventType ~ " by user " ~ req.userName ~ " from " ~ req.ipAddress
      ~ " outcome=" ~ req.outcome.to!string;
  }
}
