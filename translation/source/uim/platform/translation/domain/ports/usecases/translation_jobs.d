/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.ports.usecases.translation_jobs;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

interface IManageTranslationJobsUseCase {

    /// Submit a new async translation job — returns the job ID immediately.
    UsecaseResult submitJob(SubmitTranslationJobRequest r);

    /// Simulate processing a pending job (in production, a worker would do this).
    UsecaseResult processJob(TenantId tenantId, TranslationJobId id);

    TranslationJob[] listJobs(TenantId tenantId);

    TranslationJob getJob(TenantId tenantId, TranslationJobId id);

    UsecaseResult cancelJob(TenantId tenantId, TranslationJobId id);
    
}
