/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.job;

import uim.platform.job_scheduling.application.usecases.manage.jobs;
import uim.platform.job_scheduling.application.usecases.manage.schedules;
import uim.platform.job_scheduling.application.dto;
import uim.platform.job_scheduling.presentation.http.json_utils;

import uim.platform.job_scheduling;

class JobController : SAPController {
    private ManageJobsUseCase jobUc;
    private ManageSchedulesUseCase scheduleUc;

    this(ManageJobsUseCase jobUc, ManageSchedulesUseCase scheduleUc) {
        this.jobUc = jobUc;
        this.scheduleUc = scheduleUc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/scheduler/jobs", &handleCreate);
        router.get("/api/v1/scheduler/jobs", &handleList);
        router.get("/api/v1/scheduler/jobs/count", &handleCount);
        router.get("/api/v1/scheduler/jobs/search", &handleSearch);
        router.get("/api/v1/scheduler/jobs/*", &handleGet);
        router.put("/api/v1/scheduler/jobs/*", &handleUpdate);
        router.delete_("/api/v1/scheduler/jobs/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateJobRequest r;
            r.tenantId = req.getTenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.actionUrl = j.getString("action");
            r.httpMethod = j.getString("httpMethod");
            r.type = j.getString("type");
            r.active = jsonBool(j, "active", true);
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = jobUc.create(r);
            if (!result.success) {
                writeError(res, 400, result.error);
                return;
            }

            // Create inline schedules if provided
            auto schedulesJson = "schedules" in j;
            if (schedulesJson !is null && (*schedulesJson).type == Json.Type.array) {
                foreach (sj; *schedulesJson) {
                    CreateScheduleRequest sr;
                    sr.tenantId = r.tenantId;
                    sr.jobId = result.id;
                    sr.description = jsonStr(sj, "description");
                    sr.type = jsonStr(sj, "type");
                    sr.format = jsonStr(sj, "format");
                    sr.active = jsonBool(sj, "active", true);
                    sr.cronExpression = jsonStr(sj, "cron");
                    sr.humanReadableSchedule = jsonStr(sj, "humanReadableSchedule");
                    sr.repeatInterval = jsonLong(sj, "repeatInterval");
                    sr.repeatAt = jsonStr(sj, "repeatAt");
                    sr.time = jsonStr(sj, "time");
                    sr.startTime = jsonLong(sj, "startTime");
                    sr.endTime = jsonLong(sj, "endTime");
                    scheduleUc.create(sr);
                }
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(result.id);
            resp["message"] = Json("Job created");
            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto jobs = jobUc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref job; jobs) {
                jarr ~= jobToJson(job);
            }

            auto resp = Json.emptyObject;
            resp["total"] = Json(cast(long) jobs.length);
            resp["results"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto tenantId = req.getTenantId;

            auto job = jobUc.get_(id, tenantId);
            if (job.id.length == 0) {
                writeError(res, 404, "Job not found");
                return;
            }

            auto resp = jobToDetailJson(job);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;

            UpdateJobRequest r;
            r.tenantId = req.getTenantId;
            r.jobId = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.actionUrl = j.getString("action");
            r.httpMethod = j.getString("httpMethod");
            r.active = jsonBool(j, "active", true);
            r.startTime = jsonLong(j, "startTime");
            r.endTime = jsonLong(j, "endTime");

            auto result = jobUc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Job updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto tenantId = req.getTenantId;

            // Delete all schedules first
            scheduleUc.removeAllByJob(id, tenantId);

            auto result = jobUc.remove(id, tenantId);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCount(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto resp = Json.emptyObject;
            resp["total"] = Json(jobUc.count(tenantId));
            resp["active"] = Json(jobUc.countActive(tenantId));
            resp["inactive"] = Json(jobUc.countInactive(tenantId));
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto query = req.params.get("q", "");

            auto jobs = jobUc.search(query, tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref job; jobs) {
                jarr ~= jobToJson(job);
            }

            auto resp = Json.emptyObject;
            resp["total"] = Json(cast(long) jobs.length);
            resp["results"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json jobToJson(ref uim.platform.job_scheduling.domain.entities.job.Job job) {
        auto j = Json.emptyObject;
        j["jobId"] = Json(job.id);
        j["name"] = Json(job.name);
        j["description"] = Json(job.description);
        j["action"] = Json(job.actionUrl);
        j["active"] = Json(job.active);
        j["createdAt"] = Json(job.createdAt);
        return j;
    }

    private static Json jobToDetailJson(ref uim.platform.job_scheduling.domain.entities.job.Job job) {
        auto j = Json.emptyObject;
        j["jobId"] = Json(job.id);
        j["name"] = Json(job.name);
        j["description"] = Json(job.description);
        j["action"] = Json(job.actionUrl);
        j["httpMethod"] = Json(httpMethodStr(job.httpMethod));
        j["active"] = Json(job.active);
        j["startTime"] = Json(job.startTime);
        j["endTime"] = Json(job.endTime);
        j["createdAt"] = Json(job.createdAt);
        j["modifiedAt"] = Json(job.modifiedAt);
        return j;
    }

    private static string httpMethodStr(uim.platform.job_scheduling.domain.types.HttpMethod m) {
        final switch (m) {
            case uim.platform.job_scheduling.domain.types.HttpMethod.get: return "GET";
            case uim.platform.job_scheduling.domain.types.HttpMethod.post: return "POST";
            case uim.platform.job_scheduling.domain.types.HttpMethod.put: return "PUT";
            case uim.platform.job_scheduling.domain.types.HttpMethod.delete_: return "DELETE";
            case uim.platform.job_scheduling.domain.types.HttpMethod.patch: return "PATCH";
        }
    }
}
