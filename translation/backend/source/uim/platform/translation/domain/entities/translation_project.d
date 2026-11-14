/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.entities.translation_project;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// A software translation project: source texts (ProjectText) of one source
/// language that are translated into one or more target languages.
struct TranslationProject {
  mixin TenantEntity!TranslationProjectId;

  string name; /// unique per tenant
  string description;
  ProjectType projectType = ProjectType.api;
  string sourceLanguage = "en"; /// BCP-47 tag
  string[] targetLanguages; /// BCP-47 tags, e.g. ["de", "fr"]
  TranslationProvider provider = TranslationProvider.machineMt;
  string domainName; /// translation domain id, e.g. "FI" ("" = general)
  string repositoryUrl; /// projectType git
  string baseBranch; /// projectType git
  string abapSystemId; /// projectType abap

  // Progress (maintained by the translation runs)
  ProjectStatus status = ProjectStatus.draft;
  int textCount;
  int completionPercent; /// translated (text, language) pairs / all pairs
  long lastTranslatedAt;
}
