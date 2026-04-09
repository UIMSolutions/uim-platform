/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.run_log;

import uim.platform.job_scheduling.application.usecases.manage.run_logs;
import uim.platform.job_scheduling.application.dto;
import uim.platform.job_scheduling.presentation.http.json_utils;

import uim.platform.job_scheduling;

class RunLogController : PlatformController {
    private ManageRunLogsUseCase uc;

    this(ManageRunLogsUseCase uc) {
        this.uc = uc;
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

    private void handleListBySchedule(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            import std.string : split;
            auto path = req.requestURI.to!string;
            auto ids = extractIds(path);
            TenantId tenantId = req.getTenantId;

            auto logs = uc.listBySchedule(ids[1], ids[0], tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref l; logs) {
                jarr ~= runLogToJson(l);
            }

            auto resp = Json.emptyObject;
            resp["total"] = Json(cast(long) logs.length);
            resp["results"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleListByJob(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            import std.string : split;
            auto path = req.requestURI.to!string;
            auto jobId = extractJobId(path);
            TenantId tenantId = req.getTenantId;

            auto logs = uc.listByJob(jobId, tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref l; logs) {
                jarr ~= runLogToJson(l);
            }

            auto resp = Json.emptyObject;
            resp["total"] = Json(cast(long) logs.length);
            resp["results"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto runLogId = extractIdFromPath(path);
            auto j = req.json;

            UpdateRunLogRequest r;
            r.runLogId = runLogId;
            r.tenantId = req.getTenantId;
            r.status = j.getString("status");
            r.statusMessage = j.getString("statusMessage");
            r.httpStatus = jsonInt(j, "httpStatus");
            r.completedAt = jsonLong(j, "completedAt");
            r.executionDurationMs = jsonLong(j, "executionDurationMs");

            auto result = uc.updateStatus(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Run log updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 400, result.error);
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

    private static Json runLogToJson(ref uim.platform.job_scheduling.domain.entities.run_log.RunLog l) {
        auto j = Json.emptyObject;
        j["runLogId"] = Json(l.id);
        j["scheduleId"] = Json(l.scheduleId);
        j["jobId"] = Json(l.jobId);
        j["status"] = Json(runStatusStr(l.status));
        j["statusMessage"] = Json(l.statusMessage);
        j["httpStatus"] = Json(cast(long) l.httpStatus);
        j["scheduledAt"] = Json(l.scheduledAt);
        j["triggeredAt"] = Json(l.triggeredAt);
        j["completedAt"] = Json(l.completedAt);
        j["executionDurationMs"] = Json(l.executionDurationMs);
        j["createdAt"] = Json(l.createdAt);
        return j;
    }

    private static string runStatusStr(uim.platform.job_scheduling.domain.types.RunStatus s) {
        final switch (s) {
            case uim.platform.job_scheduling.domain.types.RunStatus.scheduled: return "scheduled";
            case uim.platform.job_scheduling.domain.types.RunStatus.triggered: return "triggered";
            case uim.platform.job_scheduling.domain.types.RunStatus.running: return "running";
            case uim.platform.job_scheduling.domain.types.RunStatus.completed: return "completed";
            case uim.platform.job_scheduling.domain.types.RunStatus.failed: return "failed";
            case uim.platform.job_scheduling.domain.types.RunStatus.deadLettered: return "deadLettered";
        }
    }
}
