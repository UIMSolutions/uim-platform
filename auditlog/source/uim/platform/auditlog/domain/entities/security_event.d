/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.entities.security_event;

// import uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());
/// Enriched security event — login/logout, auth failures, privilege changes.
@safe:
struct SecurityEvent {
  AuditLogId auditLogId; // references the parent audit entry
  TenantId tenantId;
  UserId userId;
  string userName;
  string eventType; // e.g., "login", "loginFailed", "mfaChallenge"
  string ipAddress;
  string userAgent;
  string clientId; // OAuth client id
  string identityProvider;
  string authMethod; // e.g., "password", "mfa", "sso", "certificate"
  AuditOutcome outcome = AuditOutcome.success;
  string failureReason;
  string riskLevel; // low, medium, high
  long timestamp;
}
