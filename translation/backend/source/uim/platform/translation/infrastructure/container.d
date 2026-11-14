/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.infrastructure.container;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (REST, OData, CLI, GUI) are created by the entry points
/// (app.d, cli.d, gui.d) on top of this container and only see `ports`.
class Container {
  TranslationConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  TranslationRepositories repositories;
  ITranslationEventPublisher publisher;
  SimulatedTranslationProvider provider;

  // ── Application services ──────────────────────────────────────────────
  EventRecorder events;
  Translator translator;
  ProjectTranslationService projectTranslation;

  // ── Driving ports ─────────────────────────────────────────────────────
  TranslationPorts ports;

  this(TranslationConfig config) {
    this.config = config;
    wirePersistence();
    wireApplication();
  }

  protected void wirePersistence() {
    if (config.usesFileStorage)
      storage = new JsonFileSnapshotStorage(config.dataDir);

    auto store(TEntity, TId)(string collection) {
      ITenantStore!(TEntity, TId) s = storage is null
        ? new TenantStore!(TEntity, TId)()
        : new SnapshotTenantStore!(TEntity, TId, RecordMapper!TEntity)(storage, collection);
      return s;
    }

    with (repositories) {
      projects = new ProjectRepository(store!(TranslationProject, TranslationProjectId)(TranslationCollections.projects));
      texts = new ProjectTextRepository(store!(ProjectText, ProjectTextId)(TranslationCollections.texts));
      glossary = new GlossaryRepository(store!(GlossaryEntry, GlossaryEntryId)(TranslationCollections.glossary));
      jobs = new JobRepository(store!(TranslationJob, TranslationJobId)(TranslationCollections.jobs));
    }
    publisher = new LogEventPublisher();
    provider = new SimulatedTranslationProvider(config.enabledProviders);
  }

  protected void wireApplication() {
    auto r = repositories;
    events = new EventRecorder(publisher);
    translator = new Translator(provider, r.glossary, config.policy);
    projectTranslation = new ProjectTranslationService(r, translator);

    ports.projects = new ManageProjectsUseCase(r, events, projectTranslation);
    ports.texts = new ManageProjectTextsUseCase(r, events, projectTranslation);
    ports.glossary = new ManageGlossaryUseCase(r, events);
    ports.jobs = new ManageJobsUseCase(r, events, translator, projectTranslation);
    ports.translate = new PerformTranslationUseCase(translator, publisher);
    ports.catalog = new TranslationCatalogService(provider);
    ports.statistics = new TranslationStatisticsService(r);
  }
}

/// Build the full dependency graph.
Container buildContainer(TranslationConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end scenario"));

  TranslationConfig cfg;
  cfg.storage = "memory";
  cfg.maxBatchSize = 3;
  auto c = buildContainer(cfg);
  auto p = c.ports;
  auto t = TenantId("t1");
  auto who = UserId("jane");

  // ── glossary ──────────────────────────────────────────────────────────
  CreateGlossaryEntryRequest g;
  g.tenantId = t;
  g.actor = who;
  g.spec.sourceLanguage = "EN";
  g.spec.targetLanguage = "de";
  g.spec.sourceTerm = "invoice";
  g.spec.targetTerm = "Faktura";
  g.spec.mandatory = true;
  auto gResult = p.glossary.create(g);
  assert(gResult.isSuccess, gResult.message);
  assert(p.glossary.get(t, GlossaryEntryId(gResult.id)).name == "invoice (en→de)");
  g.spec.sourceTerm = "Invoice";
  assert(p.glossary.create(g).code == 409); // same term, case-insensitive
  g.spec.targetLanguage = "en";
  assert(p.glossary.create(g).code == 422); // same language
  g.spec.targetLanguage = "de";
  g.spec.sourceTerm = "customer";
  g.spec.targetTerm = "Debitor";
  g.spec.mandatory = false;
  assert(p.glossary.create(g).isSuccess);

  // ── synchronous translation ──────────────────────────────────────────
  TranslateTextsRequest tr;
  tr.tenantId = t;
  tr.sourceLanguage = "en";
  tr.targetLanguage = "de";
  tr.texts = ["Save", "Open invoice", "Delete customer"];
  auto result = p.translate.translateTexts(tr);
  assert(result.count == 3 && result.provider == TranslationProvider.machineMt);
  assert(result.translations[0].translatedText == "Speichern");
  assert(result.translations[1].translatedText == "Öffnen Faktura" || result.translations[1].translatedText == "öffnen Faktura",
    result.translations[1].translatedText);
  assert(result.translations[1].glossaryHits == 1);
  assert(result.translations[2].translatedText == "Löschen kunde" || result.translations[2].translatedText.canFind("unde"),
    result.translations[2].translatedText); // optional entry ignored by machineMt
  tr.provider = "companyMltr";
  assert(p.translate.translateTexts(tr).translations[2].translatedText.canFind("Debitor"));
  tr.texts ~= "one too many";
  bool rejected;
  try p.translate.translateTexts(tr);
  catch (TranslationValidationException) rejected = true;
  assert(rejected);
  tr.texts = ["x"];
  tr.provider = "babelfish";
  rejected = false;
  try p.translate.translateTexts(tr);
  catch (TranslationValidationException) rejected = true;
  assert(rejected);

  TranslateDocumentRequest doc;
  doc.tenantId = t;
  doc.sourceLanguage = "en";
  doc.targetLanguage = "de";
  doc.contentType = "application/json";
  doc.content = `{"title": "Invoice", "count": 3, "items": ["Save", "Cancel"]}`;
  auto docResult = p.translate.translateDocument(doc);
  auto translatedDoc = parseJsonString(docResult.translatedContent);
  assert(translatedDoc["title"].get!string == "Faktura" && translatedDoc["count"].get!long == 3);
  assert(translatedDoc["items"][1].get!string == "Abbrechen");
  doc.contentType = "text/x-java-properties";
  doc.content = "# comment\nbutton.save=Save\nbutton.cancel=Cancel";
  assert(p.translate.translateDocument(doc).translatedContent == "# comment\nbutton.save=Speichern\nbutton.cancel=Abbrechen");

  // ── project and texts ────────────────────────────────────────────────
  CreateProjectRequest pr;
  pr.tenantId = t;
  pr.actor = who;
  pr.spec.name = "Webshop";
  pr.spec.targetLanguages = ["de", "fr", "xx"];
  assert(p.projects.create(pr).code == 422); // unsupported language
  pr.spec.targetLanguages = ["de", "FR"];
  pr.spec.projectType = ProjectType.git;
  assert(p.projects.create(pr).code == 422); // repository URL missing
  pr.spec.repositoryUrl = "https://github.com/acme/webshop.git";
  auto prResult = p.projects.create(pr);
  assert(prResult.isSuccess, prResult.message);
  auto pid = TranslationProjectId(prResult.id);
  auto project = p.projects.get(t, pid);
  assert(project.status == ProjectStatus.draft && project.targetLanguages == ["de", "fr"] && project.baseBranch == "main");
  assert(p.projects.create(pr).code == 409); // duplicate name

  CreateProjectTextRequest text;
  text.tenantId = t;
  text.actor = who;
  text.parentId = pid;
  text.spec.name = "BUTTON SAVE";
  text.spec.sourceText = "Save";
  assert(p.texts.create(text).code == 422); // blank in key
  text.spec.name = "BUTTON_SAVE";
  auto save = p.texts.create(text);
  assert(save.isSuccess, save.message);
  assert(p.texts.create(text).code == 409);
  text.spec.name = "MSG_INVOICE";
  text.spec.sourceText = "Invoice not found";
  text.spec.textType = TextType.errorMessage;
  auto msg = p.texts.create(text);
  assert(msg.isSuccess, msg.message);
  assert(p.projects.get(t, pid).textCount == 2);

  assert(p.projects.activate(t, pid, who).isSuccess);
  assert(p.projects.activate(t, pid, who).code == 409);
  auto run = p.projects.translate(t, pid, false, who);
  assert(run.isSuccess, run.message);
  project = p.projects.get(t, pid);
  assert(project.status == ProjectStatus.completed && project.completionPercent == 100, run.message);
  auto saveText = p.texts.get(t, ProjectTextId(save.id));
  assert(translationFor(saveText.translations, "de").text == "Speichern");
  assert(translationFor(saveText.translations, "fr").text == "Enregistrer");
  assert(saveText.status == TextStatus.translated);
  auto msgText = p.texts.get(t, ProjectTextId(msg.id));
  assert(translationFor(msgText.translations, "de").text == "Faktura nicht gefunden", translationFor(msgText.translations, "de").text);

  // manual translation + review
  assert(p.texts.setTranslation(t, ProjectTextId(save.id), "de", "Sichern", who).isSuccess);
  assert(p.texts.setTranslation(t, ProjectTextId(save.id), "es", "Guardar", who).code == 422);
  assert(p.texts.review(t, ProjectTextId(save.id), "fr", who).isSuccess);
  assert(p.texts.get(t, ProjectTextId(save.id)).status == TextStatus.reviewed);
  assert(p.texts.review(t, ProjectTextId(save.id), "", who).code == 409);
  p.projects.translate(t, pid, true, who); // force keeps reviewed translations
  assert(translationFor(p.texts.get(t, ProjectTextId(save.id)).translations, "de").text == "Sichern");

  // new target language → project in progress again
  UpdateProjectRequest up;
  up.tenantId = t;
  up.actor = who;
  up.id = pid;
  up.spec = decode!ProjectSpec(encode(p.projects.get(t, pid)));
  up.spec.targetLanguages = ["de", "fr", "es"];
  assert(p.projects.update(up).isSuccess);
  project = p.projects.get(t, pid);
  assert(project.status == ProjectStatus.inProgress && project.completionPercent == 66, project.completionPercent.to!string);
  up.spec.sourceLanguage = "de";
  up.spec.targetLanguages = ["fr"];
  assert(p.projects.update(up).code == 409); // source language fixed while texts exist

  // changing the source text discards its translations
  UpdateProjectTextRequest ut;
  ut.tenantId = t;
  ut.actor = who;
  ut.id = ProjectTextId(msg.id);
  ut.spec = decode!ProjectTextSpec(encode(p.texts.get(t, ut.id)));
  ut.spec.sourceText = "Invoice is required";
  assert(p.texts.update(ut).isSuccess);
  assert(p.texts.get(t, ut.id).status == TextStatus.untranslated);
  assert(p.texts.translate(t, ut.id, who).isSuccess);
  assert(translationFor(p.texts.get(t, ut.id).translations, "es").text == "Factura es obligatorio" ||
    translationFor(p.texts.get(t, ut.id).translations, "es").text.canFind("obligatorio"));

  // ── jobs ──────────────────────────────────────────────────────────────
  SubmitJobRequest job;
  job.tenantId = t;
  job.actor = who;
  job.spec.jobType = JobType.document;
  job.spec.sourceLanguage = "en";
  job.spec.targetLanguage = "fr";
  assert(p.jobs.create(job).code == 422); // no content
  job.spec.content = "Welcome\nPlease enter your password";
  auto jobResult = p.jobs.create(job);
  assert(jobResult.isSuccess, jobResult.message);
  auto jid = TranslationJobId(jobResult.id);
  assert(p.jobs.get(t, jid).status == JobStatus.pending);
  UpdateJobRequest uj;
  uj.tenantId = t;
  uj.id = jid;
  assert(p.jobs.update(uj).code == 409);

  SubmitJobRequest sw;
  sw.tenantId = t;
  sw.actor = who;
  sw.spec.jobType = JobType.software;
  sw.spec.projectId = pid;
  sw.spec.targetLanguage = "es";
  auto swResult = p.jobs.create(sw);
  assert(swResult.isSuccess, swResult.message);
  assert(p.projects.remove(t, pid, who).code == 409); // open job

  auto report = p.jobs.processPending(t);
  assert(report.processed == 2 && report.completed == 2, report.messages.join("; "));
  auto done = p.jobs.get(t, jid);
  assert(done.status == JobStatus.completed && done.translatedContent == "Bienvenue\nVeuillez saisir vos mot de passe",
    done.translatedContent);
  assert(done.qualityLevel != QualityLevel.unknown);
  assert(p.projects.get(t, pid).status == ProjectStatus.completed);
  assert(p.jobs.process(t, jid, who).code == 409);
  assert(p.jobs.cancel(t, jid, who).code == 409);

  auto third = p.jobs.create(job);
  assert(p.jobs.cancel(t, TranslationJobId(third.id), who).isSuccess);
  assert(p.jobs.retry(t, TranslationJobId(third.id), who).isSuccess);
  assert(p.jobs.process(t, TranslationJobId(third.id), who).isSuccess);

  // archived projects are read-only
  assert(p.projects.archive(t, pid, who).isSuccess);
  assert(p.texts.translate(t, ProjectTextId(save.id), who).code == 409);
  assert(p.jobs.create(sw).code == 409);
  assert(p.projects.reopen(t, pid, who).isSuccess);

  // ── statistics, catalog ──────────────────────────────────────────────
  auto stats = p.statistics.statistics(t);
  assert(stats.projects == 1 && stats.texts == 2 && stats.translations == 6 && stats.textsReviewed == 0);
  assert(stats.glossaryEntries == 2 && stats.glossaryMandatory == 1);
  assert(stats.jobs == 3 && stats.jobsCompleted == 3 && stats.averageQuality > 0);
  assert(stats.targetLanguages == ["de", "es", "fr"]);
  assert(p.catalog.languages.length > 40 && p.catalog.domains.length == 20);
  assert(p.catalog.providers.all!(x => x.available));

  // deleting a project deletes its texts
  assert(p.projects.remove(t, pid, who).isSuccess);
  assert(p.texts.list(t).length == 0);
}
