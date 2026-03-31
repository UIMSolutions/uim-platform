module uim.platform.auditlog.presentation.http.controllers.security_event;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.auditlog.application.usecases.write.security_event;
import uim.platform.auditlog.application.dto;
import uim.platform.auditlog.domain.types;
import uim.platform.auditlog.presentation.http.json_utils;

class SecurityEventController
{
    private WriteSecurityEventUseCase useCase;

    this(WriteSecurityEventUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/security-events", &handleWrite);
    }

    private void handleWrite(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = WriteSecurityEventRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.userId = jsonStr(j, "userId");
            r.userName = jsonStr(j, "userName");
            r.eventType = jsonStr(j, "eventType");
            r.ipAddress = jsonStr(j, "ipAddress");
            r.userAgent = jsonStr(j, "userAgent");
            r.clientId = jsonStr(j, "clientId");
            r.identityProvider = jsonStr(j, "identityProvider");
            r.authMethod = jsonStr(j, "authMethod");
            r.failureReason = jsonStr(j, "failureReason");
            r.riskLevel = jsonStr(j, "riskLevel");

            auto outcomeStr = jsonStr(j, "outcome");
            if (outcomeStr == "failure") r.outcome = AuditOutcome.failure;
            else if (outcomeStr == "denied") r.outcome = AuditOutcome.denied;
            else if (outcomeStr == "error") r.outcome = AuditOutcome.error;
            else r.outcome = AuditOutcome.success;

            auto result = useCase.writeEvent(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }
}
