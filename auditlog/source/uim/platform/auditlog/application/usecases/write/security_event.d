module uim.platform.auditlog.application.usecases.write.security_event;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.domain.entities.audit_log_entry;
import uim.platform.auditlog.domain.entities.security_event;
import uim.platform.auditlog.domain.ports.audit_log_repository;
import uim.platform.auditlog.domain.ports.security_event_repository;
import uim.platform.auditlog.application.dto;

@safe:
class WriteSecurityEventUseCase {
    private AuditLogRepository auditRepo;
    private SecurityEventRepository secRepo;

    this(AuditLogRepository auditRepo, SecurityEventRepository secRepo) {
        this.auditRepo = auditRepo;
        this.secRepo = secRepo;
    }

    CommandResult writeEvent(WriteSecurityEventRequest req) {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
            
        if (req.eventType.length == 0)
            return CommandResult("", "Event type is required");

        auto now = Clock.currStdTime();
        auto auditId = randomUUID().toString();

        // Create parent audit log entry
        auto entry = AuditLogEntry();
        entry.id = auditId;
        entry.tenantId = req.tenantId;
        entry.userId = req.userId;
        entry.userName = req.userName;
        entry.category = AuditCategory.securityEvents;
        entry.severity = req.outcome == AuditOutcome.failure
            ? AuditSeverity.warning : AuditSeverity.info;
        entry.action = mapEventTypeToAction(req.eventType);
        entry.outcome = req.outcome;
        entry.message = buildSecurityMessage(req);
        entry.ipAddress = req.ipAddress;
        entry.userAgent = req.userAgent;
        entry.timestamp = now;
        auditRepo.save(entry);

        // Create enriched security event
        auto secEvent = SecurityEvent();
        secEvent.auditLogId = auditId;
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
        secEvent.timestamp = now;
        secRepo.save(secEvent);

        return CommandResult(auditId, "");
    }

    private AuditAction mapEventTypeToAction(string eventType) {
        switch (eventType) {
        case "login":
            return AuditAction.login;
        case "logout":
            return AuditAction.logout;
        case "loginFailed":
            return AuditAction.loginFailed;
        case "passwordChange":
            return AuditAction.passwordChange;
        case "mfaEnroll":
            return AuditAction.mfaEnroll;
        case "mfaVerify":
            return AuditAction.mfaVerify;
        case "tokenIssue":
            return AuditAction.tokenIssue;
        case "tokenRevoke":
            return AuditAction.tokenRevoke;
        default:
            return AuditAction.login;
        }
    }

    private string buildSecurityMessage(WriteSecurityEventRequest req) {
        import std.conv : to;

        return req.eventType ~ " by user " ~ req.userName
            ~ " from " ~ req.ipAddress
            ~ " outcome=" ~ req.outcome.to!string;
    }
}
