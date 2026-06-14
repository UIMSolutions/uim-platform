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

// mixin(ShowModule!());

@safe:
class JobController : ManageHttpController {
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateJobRequest r;
            r.tenantId = tenantId;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.actionUrl = data.getString("action");
            r.httpMethod = data.getString("httpMethod");
            r.type = data.getString("type");
            r.active = data.getBoolean("active", true);
            r.startTime = getLong(j, "startTime");
            r.endTime = getLong(j, "endTime");

            auto result = usecase.createJob(r);
            if (!result.success) {
                writeError(res, 400, result.message);
                return;
            }

            foreach (sj; data.getArray("schedules")) {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

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

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = JobId(precheck.id);

            auto job = usecase.getJob(tenantId, id);
            if (job.isNull)
                return errorResponse("Job not found", 404);

            auto resp = job.toJson;
            return successResponse("Job retrieved successfully", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto jobId = JobId(precheck.id);
            auto data = precheck.data;
            UpdateJobRequest r;
            r.tenantId = tenantId;
            r.jobId = jobId;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.actionUrl = data.getString("action");
            r.httpMethod = data.getString("httpMethod");
            r.active = data.getBoolean("active", true);
            r.startTime = getLong(j, "startTime");
            r.endTime = getLong(j, "endTime");

            auto result = usecase.updateJob(r);
            if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Job updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto jobId = JobId(precheck.id);

            // Delete all schedules first
            scheduleUsecase.deleteAllSchedules(tenantId, jobId);
            auto result = usecase.deleteJob(tenantId, jobId);
            if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Job deleted successfully", 200, responseData);
    }

    protected void handleCount(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;

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
            auto tenantId = precheck.tenantId;
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
