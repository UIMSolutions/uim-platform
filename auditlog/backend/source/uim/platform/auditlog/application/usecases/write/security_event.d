/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.write.security_event;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Interactor: records an enriched security event together with its parent audit entry.
class WriteSecurityEventUseCase : IWriteSecurityEventUseCase {
  protected IAuditLogRepository auditRepo;
  protected ISecurityEventRepository secRepo;
  protected IAuditConfigRepository configRepo;

  this(IAuditLogRepository auditRepo, ISecurityEventRepository secRepo,
      IAuditConfigRepository configRepo = null) {
    this.auditRepo = auditRepo;
    this.secRepo = secRepo;
    this.configRepo = configRepo;
  }

  UsecaseResult writeEvent(WriteSecurityEventRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required", 400);
    if (req.eventType.length == 0)
      return UsecaseResult(false, "", "Event type is required", 400);

    auto severity = req.outcome == AuditOutcome.success ? AuditSeverity.info : AuditSeverity.warning;
    if (configRepo !is null) {
      try {
        AuditPolicy.ensureAllowed(configRepo.getByTenant(req.tenantId), AuditCategory.securityEvents, severity);
      } catch (AuditLogException e) {
        return UsecaseResult(false, "", e.msg, 422);
      }
    }

    auto entry = AuditLogEntry(req.tenantId);
    entry.userId = req.userId;
    entry.userName = req.userName;
    entry.category = AuditCategory.securityEvents;
    entry.severity = severity;
    entry.action = req.eventType.toAuditAction;
    entry.outcome = req.outcome;
    entry.message = buildSecurityMessage(req);
    entry.ipAddress = req.ipAddress;
    entry.userAgent = req.userAgent;
    entry.correlationId = req.correlationId;
    entry.timestamp = entry.createdAt;
    auditRepo.save(entry);

    auto secEvent = SecurityEvent(req.tenantId);
    secEvent.auditLogId = entry.id;
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

    return UsecaseResult(true, entry.id.value, "Security event recorded");
  }

  private string buildSecurityMessage(WriteSecurityEventRequest req) {
    return req.eventType ~ " by user " ~ req.userName ~ " from " ~ req.ipAddress
      ~ " outcome=" ~ req.outcome.to!string;
  }
}
///
unittest {
  mixin(ShowTest!("WriteSecurityEventUseCase"));

  auto logs = new AuditLogRepository();
  auto events = new SecurityEventRepository();
  auto uc = new WriteSecurityEventUseCase(logs, events);
  auto tenant = TenantId("t1");

  WriteSecurityEventRequest req;
  req.tenantId = tenant;
  req.eventType = "login";
  assert(uc.writeEvent(req).isSuccess);
  req.eventType = "UnknownType"; // must not throw
  assert(uc.writeEvent(req).isSuccess);
  // every event gets its own id
  assert(events.countByTenant(tenant) == 2);
  assert(logs.countByTenant(tenant) == 2);
}
