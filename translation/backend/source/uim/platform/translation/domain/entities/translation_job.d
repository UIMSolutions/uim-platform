/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.entities.translation_job;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// An asynchronous translation job (text block, document or a whole project).
/// Jobs are processed by the background worker or the "process" action.
struct TranslationJob {
  mixin TenantEntity!TranslationJobId;

  string name; /// derived: "<type> <source>→<target>"
  JobType jobType = JobType.document;
  TranslationProjectId projectId; /// jobType software
  string sourceLanguage;
  string targetLanguage; /// jobType software: "" = every target language of the project
  TranslationProvider provider = TranslationProvider.machineMt;
  string domainName;
  string contentType = "text/plain";
  string content;
  string translatedContent;
  int characterCount;
  int qualityScore;
  QualityLevel qualityLevel = QualityLevel.unknown;
  int glossaryHits;
  JobStatus status = JobStatus.pending;
  string statusMessage;
  int attempts;
  long startedAt;
  long completedAt;
}
