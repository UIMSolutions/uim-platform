/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.services.cicd_validator;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

struct CicdValidator {
    static bool isValidRepository(const CicdRepository r) {
        return r.name.length > 0 && r.url.length > 0;
    }

    static bool isValidCredential(const Credential c) {
        return c.name.length > 0;
    }

    static bool isValidPipeline(const Pipeline p) {
        return p.name.length > 0;
    }

    static bool isValidJob(const Job j) {
        return j.name.length > 0 && !j.pipelineId.isNull && !j.repositoryId.isNull;
    }

    static bool isValidBuild(const Build b) {
        return !b.jobId.isNull;
    }

    static bool isValidStage(const Stage s) {
        return s.name.length > 0 && !s.buildId.isNull;
    }

    static bool isValidWebhook(const Webhook w) {
        return !w.repositoryId.isNull && !w.jobId.isNull;
    }

    static bool isValidDeploymentTarget(const DeploymentTarget d) {
        return d.name.length > 0 && d.url.length > 0;
    }
}
