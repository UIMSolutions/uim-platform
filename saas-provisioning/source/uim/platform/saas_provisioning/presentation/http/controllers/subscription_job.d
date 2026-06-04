/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.presentation.http.controllers.subscription_job;

import uim.platform.saas_provisioning;


mixin(ShowModule!());

@safe:

/// REST controller — async subscription job status (polling).
///
///   GET /api/v1/saas-provisioning/jobs
///   GET /api/v1/saas-provisioning/jobs/*
class SubscriptionJobController : ManageHttpController {
    private ManageSubscriptionJobsUseCase usecase;

    this(ManageSubscriptionJobsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/saas-provisioning/jobs",   &handleList);
        router.get("/api/v1/saas-provisioning/jobs/*", &handleGet);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto jobs = usecase.listJobs(tenantId);
            auto arr = Json.emptyArray;
            foreach (j; jobs) arr ~= j.toJson();
            res.writeJsonBody(
                Json.emptyObject.set("count", jobs.length).set("jobs", arr), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto id = SubscriptionJobId(precheck.id);
            auto job = usecase.getJob(tenantId, id);
            if (job.isNull) { writeError(res, 404, "Job not found"); return; }
            res.writeJsonBody(job.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
