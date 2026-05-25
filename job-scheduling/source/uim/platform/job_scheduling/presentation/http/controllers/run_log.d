/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.run_log;

// import uim.platform.job_scheduling.application.usecases.manage.run_logs;
// import uim.platform.job_scheduling.application.dto;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

class RunLogController : PlatformController {
    private ManageRunLogsUseCase usecase;

    this(ManageRunLogsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        // /api/v1/scheduler/jobs/{jobId}/schedules/{scheduleId}/runLogs
        router.get("/api/v1/scheduler/jobs/*/schedules/*/runLogs", &handleListBySchedule);
        // /api/v1/scheduler/jobs/{jobId}/runLogs
        router.get("/api/v1/scheduler/jobs/*/runLogs", &handleListByJob);
        // Update run log status (async callback)
        router.put("/api/v1/scheduler/jobs/*/runLogs/*", &handleUpdateStatus);
    }

    protected void handleListBySchedule(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            import std.string : split;
            auto path = req.requestURI.to!string;
            auto ids = extractIds(path);
            auto tenantId = req.getTenantId;

            auto logs = usecase.listRunLogs(tenantId, ScheduleId(ids[1]), JobId(ids[0]));

            auto jarr = logs.map!(l => toJson(l)).array.toJson;

            auto resp = Json.emptyObject
                .set("total", logs.length)
                .set("results", jarr)
                .set("message", "Run log list retrieved successfully");
                
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleListByJob(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            import std.string : split;
            auto path = req.requestURI.to!string;
            auto jobId = JobId(extractJobId(path));
            auto tenantId = req.getTenantId;

            auto logs = usecase.listRunLogs(tenantId, jobId);

            auto jarr = logs.map!(log => toJson(log)).array.toJson;
            auto resp = Json.emptyObject
                .set("total", logs.length)
                .set("results", jarr)
                .set("message", "Run log list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto runLogId = RunLogId(extractIdFromPath(path));
            auto j = req.json;

            UpdateRunLogRequest r;
            r.runLogId = runLogId;
            r.tenantId = tenantId;
            r.status = j.getString("status");
            r.statusMessage = j.getString("statusMessage");
            r.httpStatus = j.getInteger("httpStatus");
            r.completedAt = jsonLong(j, "completedAt");
            r.executionDurationMs = jsonLong(j, "executionDurationMs");

            auto result = usecase.updateStatus(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Run log updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    // Extract jobId from path: /api/v1/scheduler/jobs/{jobId}/runLogs
    private static string extractJobId(string path) {
        import std.string : split;
        auto parts = path.split("/");
        foreach (i, p; parts) {
            if (p == "jobs" && i + 1 < parts.length)
                return parts[i + 1];
        }
        return "";
    }

    // Extract [jobId, scheduleId] from path
    private static string[2] extractIds(string path) {
        import std.string : split;
        string[2] ids;
        auto parts = path.split("/");
        foreach (i, p; parts) {
            if (p == "jobs" && i + 1 < parts.length)
                ids[0] = parts[i + 1];
            if (p == "schedules" && i + 1 < parts.length)
                ids[1] = parts[i + 1];
        }
        return ids;
    }

}
