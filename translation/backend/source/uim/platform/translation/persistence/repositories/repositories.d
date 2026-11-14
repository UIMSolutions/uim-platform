/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.persistence.repositories.repositories;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

class ProjectRepository : TranslationRepository!(TranslationProject, TranslationProjectId), IProjectRepository {
  this() {
    super();
  }

  this(ITenantStore!(TranslationProject, TranslationProjectId) store) {
    super(store);
  }

  TranslationProject findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }
}

class ProjectTextRepository : TranslationRepository!(ProjectText, ProjectTextId), IProjectTextRepository {
  this() {
    super();
  }

  this(ITenantStore!(ProjectText, ProjectTextId) store) {
    super(store);
  }

  ProjectText[] findByProject(TenantId tenantId, TranslationProjectId projectId) {
    auto result = where(tenantId, (e) => e.projectId == projectId);
    result.sort!((a, b) => a.name < b.name);
    return result;
  }

  ProjectText findByKey(TenantId tenantId, TranslationProjectId projectId, string key) {
    return first(tenantId, (e) => e.projectId == projectId && e.name == key);
  }
}

class GlossaryRepository : TranslationRepository!(GlossaryEntry, GlossaryEntryId), IGlossaryRepository {
  this() {
    super();
  }

  this(ITenantStore!(GlossaryEntry, GlossaryEntryId) store) {
    super(store);
  }

  GlossaryEntry[] findByLanguagePair(TenantId tenantId, string sourceLanguage, string targetLanguage) {
    auto s = primaryLanguage(sourceLanguage), t = primaryLanguage(targetLanguage);
    return where(tenantId, (e) => primaryLanguage(e.sourceLanguage) == s && primaryLanguage(e.targetLanguage) == t);
  }

  GlossaryEntry findByTerm(TenantId tenantId, string sourceLanguage, string targetLanguage,
      string sourceTerm, string domainName) {
    auto term = sourceTerm.toLower;
    return first(tenantId, (e) => e.sourceLanguage == sourceLanguage && e.targetLanguage == targetLanguage
        && e.sourceTerm.toLower == term && e.domainName == domainName);
  }
}

class JobRepository : TranslationRepository!(TranslationJob, TranslationJobId), IJobRepository {
  this() {
    super();
  }

  this(ITenantStore!(TranslationJob, TranslationJobId) store) {
    super(store);
  }

  TranslationJob[] findByStatus(TenantId tenantId, JobStatus status) {
    return where(tenantId, (e) => e.status == status);
  }

  TranslationJob[] findByProject(TenantId tenantId, TranslationProjectId projectId) {
    return where(tenantId, (e) => e.projectId == projectId);
  }
}

///
unittest {
  mixin(ShowTest!("Repositories"));

  assert(tenantRepositoryTest(new ProjectRepository()));
  assert(tenantRepositoryTest(new ProjectTextRepository()));
  assert(tenantRepositoryTest(new GlossaryRepository()));
  assert(tenantRepositoryTest(new JobRepository()));

  auto t = TenantId("t1");
  auto glossary = new GlossaryRepository();
  auto e = GlossaryEntry(t);
  e.sourceLanguage = "en";
  e.targetLanguage = "de";
  e.sourceTerm = "Invoice";
  glossary.save(e);
  assert(glossary.findByLanguagePair(t, "en-US", "de").length == 1);
  assert(!glossary.findByTerm(t, "en", "de", "invoice", "").isNull);
  assert(glossary.findByTerm(t, "en", "de", "invoice", "FI").isNull);

  auto texts = new ProjectTextRepository();
  auto pid = TranslationProjectId("p1");
  foreach (key; ["B", "A"]) {
    auto x = ProjectText(t);
    x.projectId = pid;
    x.name = key;
    texts.save(x);
  }
  assert(texts.findByProject(t, pid).map!(x => x.name).array == ["A", "B"]);
  assert(!texts.findByKey(t, pid, "A").isNull);
}
