/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.http.controllers.translation_job;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Async translation job management.
/// POST   /api/v1/translation/jobs         — submit a new async job
/// GET    /api/v1/translation/jobs         — list all jobs for the tenant
/// GET    /api/v1/translation/jobs/*       — get job status and result
/// POST   /api/v1/translation/jobs/*/cancel — cancel a pending job
class TranslationJobController : ManageHttpController {
    private ManageTranslationJobsUseCase usecase;

    this(ManageTranslationJobsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/translation/jobs", &handleSubmit);
        router.get("/api/v1/translation/jobs", &handleList);
        router.get("/api/v1/translation/jobs/*", &handleGet);
        router.post("/api/v1/translation/jobs/*/cancel", &handleCancel);
    }

    protected Json submitHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        SubmitTranslationJobRequest r;
        r.tenantId = tenantId;
        r.sourceLanguage = data.getString("sourceLanguage");
        r.targetLanguage = data.getString("targetLanguage");
        r.provider = data.getString("provider");
        r.content = data.getString("content");
        r.contentType = data.getString("contentType", "text/plain");

        auto jobTypeStr = data.getString("jobType", "document");
        try {
            r.jobType = jobTypeStr.to!JobType;
        } catch (Exception) {
            r.jobType = JobType.document;
        }

        auto result = usecase.submitJob(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Translation job submitted successfully", 202, Json.emptyObject.set("jobId", result
                .id));
    }

    protected void handleSubmit(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            autp response = submitHandler(req);
            res.writeJsonBody(response.body, response.code);
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

        auto arr = Json.emptyArray;
        foreach (j; jobs)
            arr ~= j.toJson;

        return successResponse("Translation jobs retrieved successfully", 200, Json.emptyObject.set("count", jobs
                .length).set("resources", arr));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TranslationJobId(precheck.id);
        auto job = usecase.getJob(tenantId, id);
        if (job.isNull)
            return errorResponse("Translation job not found", 404);

        // Include output content only when completed
        auto resp = job.toJson;
        if (job.status == JobStatus.completed)
            resp = resp.set("translatedContent", job.outputContent);

        return successResponse("Translation job retrieved successfully", 200, resp);
    }

    protected Json cancelHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        // Path is /api/v1/translation/jobs/{id}/cancel — extract id from second-to-last segment
        auto path = precheck.path;
        auto parts = path.split("/");
        auto id = TranslationJobId(parts.length >= 2 ? parts[$ - 2] : "");
        if (id.isNull)
            return errorResponse("Invalid translation job ID", 400);

        auto result = usecase.cancelJob(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Translation job cancelled successfully", 200, Json.emptyObject.set("jobId", id).set(
                "status", "cancelled"));
    }

    mixin(HandleTemplate!("handleCancel", "cancelHandler"));

}
