/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.services.statistics;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Aggregates the figures of a tenant from the repositories.
class TranslationStatisticsService : ITranslationStatisticsService {
  protected TranslationRepositories repos;

  this(TranslationRepositories repos) {
    this.repos = repos;
  }

  TranslationStatistics statistics(TenantId tenantId) {
    TranslationStatistics s;
    s.tenantId = tenantId;
    int[] scores;

    foreach (p; repos.projects.findByTenant(tenantId)) {
      s.projects++;
      final switch (p.status) {
      case ProjectStatus.draft:
        break;
      case ProjectStatus.active, ProjectStatus.inProgress:
        s.projectsActive++;
        break;
      case ProjectStatus.completed:
        s.projectsCompleted++;
        break;
      case ProjectStatus.archived:
        s.projectsArchived++;
        break;
      }
      foreach (l; p.targetLanguages)
        if (!s.targetLanguages.canFind(l))
          s.targetLanguages ~= l;
      s.lastTranslatedAt = max(s.lastTranslatedAt, p.lastTranslatedAt);
    }
    s.targetLanguages.sort();

    foreach (t; repos.texts.findByTenant(tenantId)) {
      s.texts++;
      if (t.status == TextStatus.translated || t.status == TextStatus.reviewed)
        s.textsTranslated++;
      if (t.status == TextStatus.reviewed)
        s.textsReviewed++;
      foreach (tr; t.translations)
        if (tr.text.length > 0) {
          s.translations++;
          scores ~= tr.qualityScore;
          s.charactersTranslated += t.sourceText.length;
        }
    }

    foreach (g; repos.glossary.findByTenant(tenantId)) {
      s.glossaryEntries++;
      if (g.mandatory)
        s.glossaryMandatory++;
    }

    foreach (j; repos.jobs.findByTenant(tenantId)) {
      s.jobs++;
      final switch (j.status) {
      case JobStatus.pending, JobStatus.processing:
        s.jobsPending++;
        break;
      case JobStatus.completed:
        s.jobsCompleted++;
        if (j.jobType != JobType.software) {
          scores ~= j.qualityScore;
          s.charactersTranslated += j.characterCount;
        }
        s.lastTranslatedAt = max(s.lastTranslatedAt, j.completedAt);
        break;
      case JobStatus.failed:
        s.jobsFailed++;
        break;
      case JobStatus.cancelled:
        s.jobsCancelled++;
        break;
      }
    }
    s.averageQuality = averageQuality(scores);
    return s;
  }
}
