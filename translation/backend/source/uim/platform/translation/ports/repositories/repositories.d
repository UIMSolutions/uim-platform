/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.repositories.repositories;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

interface IProjectRepository : ITenantRepository!(TranslationProject, TranslationProjectId) {
  TranslationProject findByName(TenantId tenantId, string name);
}

interface IProjectTextRepository : ITenantRepository!(ProjectText, ProjectTextId) {
  ProjectText[] findByProject(TenantId tenantId, TranslationProjectId projectId);
  /// The text with this key in a project (ProjectText.init if unknown).
  ProjectText findByKey(TenantId tenantId, TranslationProjectId projectId, string key);
}

interface IGlossaryRepository : ITenantRepository!(GlossaryEntry, GlossaryEntryId) {
  /// Entries of a language pair (primary subtags compared).
  GlossaryEntry[] findByLanguagePair(TenantId tenantId, string sourceLanguage, string targetLanguage);
  /// The entry for a term (case-insensitive) within pair and domain.
  GlossaryEntry findByTerm(TenantId tenantId, string sourceLanguage, string targetLanguage,
    string sourceTerm, string domainName);
}

interface IJobRepository : ITenantRepository!(TranslationJob, TranslationJobId) {
  TranslationJob[] findByStatus(TenantId tenantId, JobStatus status);
  TranslationJob[] findByProject(TenantId tenantId, TranslationProjectId projectId);
}
