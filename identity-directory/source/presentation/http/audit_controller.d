module presentation.http.audit_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.use_cases.query_audit_log;
import domain.entities.audit_event;
import presentation.http.json_utils;

/// HTTP controller for audit log queries.
class AuditController
{
    private QueryAuditLogUseCase useCase;

    this(QueryAuditLogUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.get("/api/v1/audit-logs", &handleList);
        router.get("/api/v1/audit-logs/actor/*", &handleByActor);
        router.get("/api/v1/audit-logs/target/*", &handleByTarget);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto events = useCase.listEvents(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) events.length);
            response["resources"] = toJsonArray(events);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleByActor(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto actorId = extractIdFromPath(req.requestURI);
            auto events = useCase.findByActor(actorId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) events.length);
            response["resources"] = toJsonArray(events);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleByTarget(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto targetId = extractIdFromPath(req.requestURI);
            auto events = useCase.findByTarget(targetId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) events.length);
            response["resources"] = toJsonArray(events);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }
}
