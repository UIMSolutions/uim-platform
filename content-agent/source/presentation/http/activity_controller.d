module presentation.http.activity;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.content_agent.application.usecases.monitor_activities;
import domain.entities.content_activity;
import domain.types;
import presentation.http.json_utils;

class ActivityController
{
    private MonitorActivitiesUseCase uc;

    this(MonitorActivitiesUseCase uc)
    {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router)
    {
        router.get("/api/v1/activities", &handleList);
        router.get("/api/v1/activities/summary", &handleSummary);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto activities = uc.listActivities(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref a; activities)
                arr ~= serializeActivity(a);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) activities.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSummary(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto summary = uc.getSummary(tenantId);

            auto j = Json.emptyObject;
            j["totalCount"] = Json(summary.totalCount);
            j["infoCount"] = Json(summary.infoCount);
            j["warningCount"] = Json(summary.warningCount);
            j["errorCount"] = Json(summary.errorCount);
            res.writeJsonBody(j, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeActivity(ref const ContentActivity a)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(a.id);
        j["tenantId"] = Json(a.tenantId);
        j["activityType"] = Json(a.activityType.to!string);
        j["severity"] = Json(a.severity.to!string);
        j["entityId"] = Json(a.entityId);
        j["entityName"] = Json(a.entityName);
        j["description"] = Json(a.description);
        j["performedBy"] = Json(a.performedBy);
        j["timestamp"] = Json(a.timestamp);
        j["details"] = Json(a.details);
        return j;
    }
}
