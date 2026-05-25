/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.job;

// import uim.platform.job_scheduling.application.usecases.manage.jobs;
// import uim.platform.job_scheduling.application.usecases.manage.schedules;
// import uim.platform.job_scheduling.application.dto;

// import uim.platform.job_scheduling;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
class JobController : PlatformController {
    private ManageJobsUseCase usecase;
    private ManageSchedulesUseCase scheduleUsecase;

    this(ManageJobsUseCase usecase, ManageSchedulesUseCase scheduleUsecase) {
        this.usecase = usecase;
        this.scheduleUsecase = scheduleUsecase;
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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateJobRequest r;
            r.tenantId = tenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.actionUrl = j.getString("action");
            r.httpMethod = j.getString("httpMethod");
            r.type = j.getString("type");
            r.active = j.getBoolean("active", true);
            r.startTime = getLong(j, "startTime");
            r.endTime = getLong(j, "endTime");

            auto result = usecase.createJob(r);
            if (!result.success) {
                writeError(res, 400, result.message);
                return;
            }

            foreach (sj; j.getArray("schedules")) {
                CreateScheduleRequest sr;
                sr.tenantId = r.tenantId;
                sr.jobId = result.id;
                sr.description = getString(sj, "description");
                sr.type = getString(sj, "type");
                sr.format = getString(sj, "format");
                sr.active = getBoolean(sj, "active", true);
                sr.cronExpression = getString(sj, "cron");
                sr.humanReadableSchedule = getString(sj, "humanReadableSchedule");
                sr.repeatInterval = getLong(sj, "repeatInterval");
                sr.repeatAt = getLong(sj, "repeatAt");
                sr.time = getLong(sj, "time");
                sr.startTime = getLong(sj, "startTime");
                sr.endTime = getLong(sj, "endTime");

                scheduleUsecase.createSchedule(sr);
            }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "Job created");

            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto jobs = usecase.listJobs(tenantId);

            auto jarr = jobs.map!(job => job.toJson).array.toJson;
            auto resp = Json.emptyObject
                .set("total", jobs.length)
                .set("results", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = JobId(extractIdFromPath(req.requestURI.to!string));

            auto job = usecase.getJob(tenantId, id);
            if (job.isNull) {
                writeError(res, 404, "Job not found");
                return;
            }

            auto resp = job.toJson();
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto jobId = JobId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;

            UpdateJobRequest r;
            r.tenantId = tenantId;
            r.jobId = jobId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.actionUrl = j.getString("action");
            r.httpMethod = j.getString("httpMethod");
            r.active = j.getBoolean("active", true);
            r.startTime = getLong(j, "startTime");
            r.endTime = getLong(j, "endTime");

            auto result = usecase.updateJob(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Job updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto jobId = JobId(extractIdFromPath(req.requestURI.to!string));

            // Delete all schedules first
            scheduleUsecase.deleteAllSchedules(tenantId, jobId);
            auto result = usecase.deleteJob(tenantId, jobId);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCount(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto resp = Json.emptyObject
                .set("total", usecase.countJobs(tenantId))
                .set("active", usecase.countActiveJobs(tenantId))
                .set("inactive", usecase.countInactiveJobs(tenantId));

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleSearch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto query = req.params.get("q", "");

            auto jobs = usecase.searchJobs(tenantId, query);
            auto jarr = jobs.map!(job => job.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("total", jobs.length)
                .set("results", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
