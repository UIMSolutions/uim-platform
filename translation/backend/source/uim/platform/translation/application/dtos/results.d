/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.dtos.results;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// One translated text.
struct TranslatedText {
  string sourceText;
  string translatedText;
  int qualityScore;
  QualityLevel qualityLevel = QualityLevel.unknown;
  int glossaryHits;
  bool truncationRisk; /// longer than the text type / maxLength allows
}

/// Result of a synchronous text translation.
struct TranslateTextsResult {
  string sourceLanguage;
  string targetLanguage;
  TranslationProvider provider;
  string domainName;
  TextType textType;
  int count;
  int averageQuality;
  int glossaryHits;
  TranslatedText[] translations;
}

/// Result of a synchronous document translation.
struct DocumentTranslationResult {
  string sourceLanguage;
  string targetLanguage;
  TranslationProvider provider;
  string contentType;
  string translatedContent;
  int characterCount;
  int qualityScore;
  QualityLevel qualityLevel = QualityLevel.unknown;
  int glossaryHits;
}

/// Outcome of a job processing pass.
struct JobRunReport {
  TenantId tenantId;
  int processed;
  int completed;
  int failed;
  string[] messages;
  long ranAt;
}

/// A translation provider and its availability.
struct ProviderInfo {
  string id; /// TranslationProvider name
  string name;
  string description;
  bool available;
}

/// Aggregated figures of a tenant (Fiori KPI header, CLI "stats", GUI overview).
struct TranslationStatistics {
  TenantId tenantId;
  int projects;
  int projectsActive; /// active + inProgress
  int projectsCompleted;
  int projectsArchived;
  int texts;
  int textsTranslated; /// translated + reviewed
  int textsReviewed;
  int translations; /// (text, language) pairs translated
  int averageQuality;
  int glossaryEntries;
  int glossaryMandatory;
  int jobs;
  int jobsPending; /// pending + processing
  int jobsCompleted;
  int jobsFailed;
  int jobsCancelled;
  long charactersTranslated;
  string[] targetLanguages; /// in use by projects
  long lastTranslatedAt;
}
