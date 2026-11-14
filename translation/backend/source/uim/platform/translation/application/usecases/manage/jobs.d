/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.manage.jobs;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Interactor: asynchronous translation jobs. Jobs are immutable once
/// submitted; they are processed by the worker or the "process" action.
class ManageJobsUseCase
  : ResourceUseCase!(TranslationJob, TranslationJobId, SubmitJobRequest, UpdateJobRequest),
  IManageJobsUseCase {

  protected Translator translator;
  protected ProjectTranslationService projects;

  this(TranslationRepositories repos, EventRecorder events, Translator translator, ProjectTranslationService projects) {
    super(repos, repos.jobs, events, "Job", "translation.job");
    this.translator = translator;
    this.projects = projects;
  }

  override protected TranslationJob build(SubmitJobRequest r) {
    auto j = TranslationJob(r.tenantId);
    assignMatching(j, r.spec);
    if (j.jobType == JobType.software) {
      auto project = requireProject(r.tenantId, j.projectId);
      ensureWritable(project);
      j.projectId = project.id;
      j.sourceLanguage = project.sourceLanguage;
      j.provider = project.provider;
      j.domainName = project.domainName;
      if (j.targetLanguage.strip.length > 0) {
        j.targetLanguage = normalizeLanguage(j.targetLanguage);
        validate(project.targetLanguages.canFind(j.targetLanguage),
          "'" ~ j.targetLanguage ~ "' is not a target language of '" ~ project.name ~ "'");
      }
      j.content = "";
      j.name = jobName(j.jobType, j.sourceLanguage, j.targetLanguage, project.name);
    } else {
      j.projectId = TranslationProjectId.init;
      j.sourceLanguage = requireLanguage("Source language", j.sourceLanguage);
      j.targetLanguage = requireLanguage("Target language", j.targetLanguage);
      validateLanguagePair(j.sourceLanguage, j.targetLanguage);
      j.domainName = requireDomain(j.domainName);
      validate(j.content.strip.length > 0, "Content is required");
      validate(j.content.length <= translator.limits.maxDocumentLength,
        "Content exceeds " ~ translator.limits.maxDocumentLength.to!string ~ " characters");
      j.characterCount = cast(int) j.content.length;
      j.name = jobName(j.jobType, j.sourceLanguage, j.targetLanguage);
    }
    j.status = JobStatus.pending;
    j.statusMessage = "Waiting for processing";
    return j;
  }

  override protected void apply(ref TranslationJob j, JobSpec spec) {
    throw new TranslationConflictException("Jobs cannot be changed — cancel the job and submit a new one");
  }

  override protected void beforeRemove(TranslationJob j) {
    ensureRemovable(j);
  }

  UsecaseResult process(TenantId tenantId, TranslationJobId id, UserId actor) {
    return guarded(() {
      auto j = require(tenantId, id);
      ensureProcessable(j);
      run(j, actor);
      return j.status == JobStatus.completed ? succeeded(j.id.value, "Job '" ~ j.name ~ "' completed: " ~ j.statusMessage)
        : UsecaseResult(false, j.id.value, "Job '" ~ j.name ~ "' failed: " ~ j.statusMessage, 422);
    });
  }

  JobRunReport processPending(TenantId tenantId, int limit = 0) {
    JobRunReport report;
    report.tenantId = tenantId;
    report.ranAt = nowStdTime();
    auto pending = repos.jobs.findByStatus(tenantId, JobStatus.pending);
    pending.sort!((a, b) => a.createdAt < b.createdAt);
    foreach (j; pending) {
      if (limit > 0 && report.processed >= limit)
        break;
      run(j, UserId("worker"));
      report.processed++;
      if (j.status == JobStatus.completed)
        report.completed++;
      else
        report.failed++;
      report.messages ~= j.name ~ ": " ~ enumText(j.status) ~ " — " ~ j.statusMessage;
    }
    return report;
  }

  /// Process one job; failures are stored in the job, never thrown.
  protected void run(ref TranslationJob j, UserId actor) {
    j.status = JobStatus.processing;
    j.startedAt = nowStdTime();
    j.attempts++;
    j.statusMessage = "Processing";
    j.update(actor);
    repo.update(j);
    try {
      final switch (j.jobType) {
      case JobType.text, JobType.document:
        auto r = translator.translateDocument(j.tenantId, j.content, j.contentType, j.sourceLanguage,
          j.targetLanguage, j.provider, j.domainName);
        j.translatedContent = r.translatedContent;
        j.qualityScore = r.qualityScore;
        j.glossaryHits = r.glossaryHits;
        j.statusMessage = "%d characters translated".format(r.characterCount);
        break;
      case JobType.software:
        auto project = requireProject(j.tenantId, j.projectId);
        ensureWritable(project);
        auto langs = j.targetLanguage.length ? [j.targetLanguage] : project.targetLanguages;
        auto r = projects.translateProject(project, langs, false, actor);
        j.characterCount = cast(int) r.characters;
        j.qualityScore = averageQuality(r.scores);
        j.glossaryHits = r.glossaryHits;
        j.statusMessage = "%d translation(s) for %d text(s)".format(r.translations, r.texts);
        break;
      }
      j.qualityLevel = qualityLevelOf(j.qualityScore);
      j.status = JobStatus.completed;
    } catch (TranslationException e) {
      j.status = JobStatus.failed;
      j.statusMessage = e.msg;
    }
    // cancelled while processing?
    auto current = repo.findById(j.tenantId, j.id);
    if (!current.isNull && current.status == JobStatus.cancelled)
      j.status = JobStatus.cancelled;
    j.completedAt = nowStdTime();
    j.update(actor);
    repo.update(j);
    publish(j, enumText(j.status));
  }

  UsecaseResult cancel(TenantId tenantId, TranslationJobId id, UserId actor) {
    return transition(tenantId, id, actor, "cancelled", (ref j) {
      ensureCancellable(j);
      j.status = JobStatus.cancelled;
      j.statusMessage = "Cancelled by " ~ (actor.isEmpty ? "user" : actor.value);
      j.completedAt = nowStdTime();
    });
  }

  UsecaseResult retry(TenantId tenantId, TranslationJobId id, UserId actor) {
    return transition(tenantId, id, actor, "resubmitted", (ref j) {
      ensureRetryable(j);
      j.status = JobStatus.pending;
      j.statusMessage = "Waiting for processing (retry)";
      j.translatedContent = "";
      j.completedAt = 0;
    });
  }
}
