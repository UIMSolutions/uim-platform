/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Statistics of a tenant (KPI header, CLI "stats").
module uim.platform.document_ai.application.services.statistics;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class DaiStatisticsService : IDaiStatisticsService {
  protected DaiRepositories repos;
  protected IClock clock;

  this(DaiRepositories repos, IClock clock) {
    this.repos = repos;
    this.clock = clock;
  }

  DaiStatistics compute(TenantId t) {
    DaiStatistics s;
    s.tenantId = t;
    auto since = plusDays(clock.now, -1);
    double confidenceSum = 0;
    long extractedDocuments;
    bool[string] confirmed;
    foreach (d; repos.documents.findAll(t)) {
      s.documents++;
      if (d.createdAt >= since)
        s.documentsLast24h++;
      final switch (d.status) {
      case DocumentStatus.pending:
        s.pendingDocuments++;
        break;
      case DocumentStatus.done:
        s.doneDocuments++;
        if (d.needsReview)
          s.reviewDocuments++;
        break;
      case DocumentStatus.confirmed:
        s.confirmedDocuments++;
        confirmed[d.id.value] = true;
        break;
      case DocumentStatus.rejected:
        s.rejectedDocuments++;
        break;
      case DocumentStatus.failed:
        s.failedDocuments++;
        break;
      }
      if (d.extractedFieldCount > 0) {
        extractedDocuments++;
        confidenceSum += d.overallConfidence;
      }
      if (d.matchStatus == MatchStatus.matched)
        s.matchedDocuments++;
    }
    s.averageConfidence = extractedDocuments ? cast(long)(confidenceSum * 100 / extractedDocuments + 0.5) : 0;
    long confirmedFields, confirmedCorrections;
    foreach (f; repos.extractedFields.findAll(t)) {
      s.extractedFields++;
      if (f.corrected)
        s.correctedFields++;
      if (f.documentId.value in confirmed) {
        confirmedFields++;
        if (f.corrected)
          confirmedCorrections++;
      }
    }
    s.correctionRate = confirmedFields ? confirmedCorrections * 100 / confirmedFields : 0;
    foreach (sc; repos.schemas.findAll(t)) {
      s.schemas++;
      if (sc.isActive)
        s.activeSchemas++;
    }
    s.templates = repos.templates.countAll(t);
    s.documentTypes = repos.documentTypes.countAll(t);
    s.enrichmentRecords = repos.enrichmentData.countAll(t);
    s.clients = repos.clients.countAll(t);
    double best = 0;
    foreach (j; repos.trainingJobs.findAll(t)) {
      s.trainingJobs++;
      if (j.status == TrainingJobStatus.running)
        s.runningTrainingJobs++;
      if (j.status == TrainingJobStatus.completed && j.accuracy > best)
        best = j.accuracy;
    }
    s.bestAccuracy = cast(long)(best * 100 + 0.5);
    return s;
  }
}
