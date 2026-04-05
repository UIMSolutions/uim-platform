/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.schedule;

import uim.platform.job_scheduling.application.usecases.manage.schedules;
import uim.platform.job_scheduling.application.dto;
import uim.platform.job_scheduling.presentation.http.json_utils;

import uim.platform.job_scheduling;

class ScheduleController : SAPController {
    private ManageSchedulesUseCase uc;

    this(ManageSchedulesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        // /api/v1/scheduler/jobs/{jobId}/schedules
        router.post("/api/v1/scheduler/jobs/*/schedules", &handleCreate);
        router.get("/api/v1/scheduler/jobs/*/schedules", &handleList);
        router.put("/api/v1/scheduler/jobs/*/schedules/activate", &handleActivateAll);
        router.get("/api/v1/scheduler/jobs/*/schedules/*", &handleGet);
        router.put("/api/v1/scheduler/jobs/*/schedules/*", &handleUpdate);
        router.delete_("/api/v1/scheduler/jobs/*/schedules/*", &handleDelete);
        // Search across all jobs
        router.get("/api/v1/scheduler/schedules/search", &handleSearch);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto jobId = extractJobIdFromSchedulePath(path);
            auto j = req.json;

            CreateScheduleRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.jobId = jobId;
            r.description = jsonStr(j, "description");
            r.type = jsonStr(j, "type");
            r.format = jsonStr(j, "format");
            r.active = jsonBool(j, "active", true);
            r.cronExpression = jsonStr(j, "cron");
            r.humanReadableSchedule = jsonStr(j, "humanReadableSchedule");
            r.repeatInterval = jsonLong(j, "repeatInterval");
            r.repeatAt = jsonStr(j, "repeatAt");
            r.time = jsonStr(j, "time");
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["jobId"] = Json(jobId);
                resp["message"] = Json("Schedule created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto jobId = extractJobIdFromSchedulePath(path);
            auto tenantId = req.headers.get("X-Tenant-Id", "");

            auto schedules = uc.list(jobId, tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref s; schedules) {
                jarr ~= scheduleToJson(s);
            }

            auto resp = Json.emptyObject;
            resp["total"] = Json(cast(long) schedules.length);
            resp["results"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto ids = extractJobAndScheduleIds(path);
            auto tenantId = req.headers.get("X-Tenant-Id", "");

            auto s = uc.get_(ids[1], ids[0], tenantId);
            if (s.id.length == 0) {
                writeError(res, 404, "Schedule not found");
                return;
            }

            res.writeJsonBody(scheduleToDetailJson(s), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto ids = extractJobAndScheduleIds(path);
            auto j = req.json;

            UpdateScheduleRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.jobId = ids[0];
            r.scheduleId = ids[1];
            r.description = jsonStr(j, "description");
            r.active = jsonBool(j, "active", true);
            r.cronExpression = jsonStr(j, "cron");
            r.humanReadableSchedule = jsonStr(j, "humanReadableSchedule");
            r.repeatInterval = jsonLong(j, "repeatInterval");
            r.repeatAt = jsonStr(j, "repeatAt");
            r.time = jsonStr(j, "time");
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Schedule updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto ids = extractJobAndScheduleIds(path);
            auto tenantId = req.headers.get("X-Tenant-Id", "");

            auto result = uc.remove(ids[1], ids[0], tenantId);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleActivateAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto jobId = extractJobIdFromSchedulePath(path);
            auto j = req.json;

            ActivateAllSchedulesRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.jobId = jobId;
            r.active = jsonBool(j, "active", true);

            auto result = uc.activateAll(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json(r.active ? "All schedules activated" : "All schedules deactivated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto query = req.params.get("q", "");

            auto schedules = uc.search(query, tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref s; schedules) {
                jarr ~= scheduleToJson(s);
            }

            auto resp = Json.emptyObject;
            resp["total"] = Json(cast(long) schedules.length);
            resp["results"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    // Extract jobId from path: /api/v1/scheduler/jobs/{jobId}/schedules
    private static string extractJobIdFromSchedulePath(string path) {
        import std.string : split;
        auto parts = path.split("/");
        // parts: ["", "api", "v1", "scheduler", "jobs", "{jobId}", "schedules", ...]
        foreach (i, p; parts) {
            if (p == "jobs" && i + 1 < parts.length)
                return parts[i + 1];
        }
        return "";
    }

    // Extract [jobId, scheduleId] from path: /api/v1/scheduler/jobs/{jobId}/schedules/{scheduleId}
    private static string[2] extractJobAndScheduleIds(string path) {
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

    private static Json scheduleToJson(
            ref uim.platform.job_scheduling.domain.entities.schedule.Schedule s) {
        auto j = Json.emptyObject;
        j["scheduleId"] = Json(s.id);
        j["jobId"] = Json(s.jobId);
        j["description"] = Json(s.description);
        j["active"] = Json(s.active);
        j["nextRunAt"] = Json(s.nextRunAt);
        j["createdAt"] = Json(s.createdAt);
        return j;
    }

    private static Json scheduleToDetailJson(
            ref uim.platform.job_scheduling.domain.entities.schedule.Schedule s) {
        auto j = Json.emptyObject;
        j["scheduleId"] = Json(s.id);
        j["jobId"] = Json(s.jobId);
        j["description"] = Json(s.description);
        j["active"] = Json(s.active);
        j["cron"] = Json(s.cronExpression);
        j["humanReadableSchedule"] = Json(s.humanReadableSchedule);
        j["repeatInterval"] = Json(s.repeatInterval);
        j["repeatAt"] = Json(s.repeatAt);
        j["time"] = Json(s.time);
        j["startTime"] = Json(s.startTime);
        j["endTime"] = Json(s.endTime);
        j["nextRunAt"] = Json(s.nextRunAt);
        j["createdAt"] = Json(s.createdAt);
        j["modifiedAt"] = Json(s.modifiedAt);
        return j;
    }
}
