/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.security_event;
// 
// 
// import uim.platform.auditlog.application.usecases.write.security_event;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class SecurityEventController : HttpController {
  private WriteSecurityEventUseCase useCase;

  this(WriteSecurityEventUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/security-events", &handleWrite);
  }

  protected Json writeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto r = WriteSecurityEventRequest();
    r.tenantId = tenantId;
    r.userId = data.getString("userId");
    r.userName = data.getString("userName");
    r.eventType = data.getString("eventType");
    r.ipAddress = data.getString("ipAddress");
    r.userAgent = data.getString("userAgent");
    r.clientId = data.getString("clientId");
    r.identityProvider = data.getString("identityProvider");
    r.authMethod = data.getString("authMethod");
    r.failureReason = data.getString("failureReason");
    r.riskLevel = data.getString("riskLevel");

    auto outcomeStr = data.getString("outcome");
    if (outcomeStr == "failure")
      r.outcome = AuditOutcome.failure;
    else if (outcomeStr == "denied")
      r.outcome = AuditOutcome.denied;
    else if (outcomeStr == "error")
      r.outcome = AuditOutcome.error;
    else
      r.outcome = AuditOutcome.success;

    auto result = useCase.writeEvent(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Security event recorded successfully", 201, resp);
  }

  mixin(HandleTemplate!("handleWrite", "writeHandler"));

}
