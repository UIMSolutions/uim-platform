/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.manage.translation_jobs;

import uim.platform.translation;


// mixin(ShowModule!());

@safe:

class ManageTranslationJobsUseCase {
    private TranslationJobRepository repo;
    private TranslationEngine engine;

    this(TranslationJobRepository repo, TranslationEngine engine) {
        this.repo = repo;
        this.engine = engine;
    }

    /// Submit a new async translation job — returns the job ID immediately.
    CommandResult submitJob(SubmitTranslationJobRequest r) {
        if (r.content.length == 0)
            return CommandResult(false, "", "Content is required");
        if (r.sourceLanguage.length == 0 || r.targetLanguage.length == 0)
            return CommandResult(false, "", "Source and target languages are required");

        TranslationJob job;
        job.initEntity(r.tenantId);
        job.jobType = r.jobType;
        job.sourceLanguage = r.sourceLanguage;
        job.targetLanguage = r.targetLanguage;
        job.inputContent = r.content;
        job.contentType = r.contentType;
        job.status = JobStatus.pending;

        try { job.provider = r.provider.to!TranslationProvider; }
        catch (Exception) { job.provider = TranslationProvider.machineMt; }

        repo.save(job);
        return CommandResult(true, job.id.value, "");
    }

    /// Simulate processing a pending job (in production, a worker would do this).
    CommandResult processJob(TenantId tenantId, TranslationJobId id) {
        auto job = repo.findById(tenantId, id);
        if (job.isNull)
            return CommandResult(false, "", "Translation job not found");
        if (job.status != JobStatus.pending)
            return CommandResult(false, "", "Job is not in pending state");

        job.status = JobStatus.processing;
        repo.update(job);

        auto result = engine.translate(job.inputContent, job.sourceLanguage, job.targetLanguage, job.provider);
        job.outputContent = result.translatedText;
        job.qualityScore = result.qualityScore;
        job.status = JobStatus.completed;
        job.completedAt = MonoTime.currTime.ticks;

        repo.update(job);
        return CommandResult(true, job.id.value, "");
    }

    TranslationJob[] listJobs(TenantId tenantId) {
        return repo.find(tenantId);
    }

    TranslationJob getJob(TenantId tenantId, TranslationJobId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult cancelJob(TenantId tenantId, TranslationJobId id) {
        auto job = repo.findById(tenantId, id);
        if (job.isNull)
            return CommandResult(false, "", "Translation job not found");
        if (job.status == JobStatus.completed || job.status == JobStatus.failed)
            return CommandResult(false, "", "Cannot cancel a finished job");

        job.status = JobStatus.cancelled;
        repo.update(job);
        return CommandResult(true, job.id.value, "");
    }
}
