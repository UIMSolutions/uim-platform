/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the statistics (KPI header of the Fiori app, CLI "stats").
module uim.platform.document_ai.ports.services.statistics;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct DaiStatistics {
  TenantId tenantId;
  long documents;
  long pendingDocuments;
  long doneDocuments; /// extracted, waiting for review / confirmation
  long reviewDocuments; /// done with low confidence or missing required values
  long confirmedDocuments;
  long rejectedDocuments;
  long failedDocuments;
  long documentsLast24h;
  long extractedFields;
  long correctedFields;
  long correctionRate; /// % of the values of confirmed documents that were corrected
  long averageConfidence; /// % (mean of the extracted documents)
  long matchedDocuments; /// with an enrichment match
  long schemas;
  long activeSchemas;
  long templates;
  long documentTypes;
  long enrichmentRecords;
  long clients;
  long trainingJobs;
  long runningTrainingJobs;
  long bestAccuracy; /// % of the best completed training job
}

interface IDaiStatisticsService {
  DaiStatistics compute(TenantId t);
}
