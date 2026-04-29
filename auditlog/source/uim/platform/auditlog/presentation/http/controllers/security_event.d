/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.security_event;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.auditlog.application.usecases.write.security_event;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class SecurityEventController : PlatformController {
  private WriteSecurityEventUseCase useCase;

  this(WriteSecurityEventUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/security-events", &handleWrite);
  }

  private void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = WriteSecurityEventRequest();
      r.tenantId = req.getTenantId;
      r.userId = j.getString("userId");
      r.userName = j.getString("userName");
      r.eventType = j.getString("eventType");
      r.ipAddress = j.getString("ipAddress");
      r.userAgent = j.getString("userAgent");
      r.clientId = j.getString("clientId");
      r.identityProvider = j.getString("identityProvider");
      r.authMethod = j.getString("authMethod");
      r.failureReason = j.getString("failureReason");
      r.riskLevel = j.getString("riskLevel");

      auto outcomeStr = j.getString("outcome");
      if (outcomeStr == "failure")
        r.outcome = AuditOutcome.failure;
      else if (outcomeStr == "denied")
        r.outcome = AuditOutcome.denied;
      else if (outcomeStr == "error")
        r.outcome = AuditOutcome.error;
      else
        r.outcome = AuditOutcome.success;

      auto result = useCase.writeEvent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Security event recorded");
          
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
