/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.manage.texts;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Interactor: source texts of a project. Text keys are unique per project;
/// changing the source text discards its translations.
class ManageProjectTextsUseCase
  : ResourceUseCase!(ProjectText, ProjectTextId, CreateProjectTextRequest, UpdateProjectTextRequest),
  IManageProjectTextsUseCase {

  protected ProjectTranslationService service;

  this(TranslationRepositories repos, EventRecorder events, ProjectTranslationService service) {
    super(repos, repos.texts, events, "Text", "translation.text");
    this.service = service;
  }

  override protected ProjectText build(CreateProjectTextRequest r) {
    auto project = requireProject(r.tenantId, r.parentId);
    ensureWritable(project);
    auto t = ProjectText(r.tenantId);
    assignMatching(t, r.spec);
    t.projectId = project.id;
    t.projectName = project.name;
    t.name = t.name.strip;
    check(t);
    ensureUnique(repos.texts.findByKey(r.tenantId, project.id, t.name), t, "project '" ~ project.name ~ "'");
    t.status = TextStatus.untranslated;
    return t;
  }

  /// The key is the identity used by the application and cannot change.
  override protected void apply(ref ProjectText t, ProjectTextSpec spec) {
    auto project = requireProject(t.tenantId, t.projectId);
    ensureWritable(project);
    auto sourceBefore = t.sourceText;
    assignMatching(t, spec, ["name"]);
    check(t);
    if (t.sourceText != sourceBefore)
      t.translations = null; // outdated
    t.status = textStatusOf(t.translations, project.targetLanguages);
  }

  protected void check(ref ProjectText t) {
    validateTextKey(t.name);
    validate(t.sourceText.strip.length > 0, "Source text is required");
    validate(t.sourceText.length <= 5000, "Source text must not exceed 5000 characters");
    validate(t.maxLength >= 0, "maxLength must not be negative");
  }

  override protected void beforeRemove(ProjectText t) {
    auto project = repos.projects.findById(t.tenantId, t.projectId);
    if (!project.isNull)
      ensureWritable(project);
  }

  override protected void afterCreate(ProjectText t, UserId actor) {
    service.refresh(t.tenantId, t.projectId);
  }

  override protected void afterUpdate(ProjectText before, ProjectText after, UserId actor) {
    service.refresh(after.tenantId, after.projectId);
  }

  override protected void afterRemove(ProjectText t, UserId actor) {
    service.refresh(t.tenantId, t.projectId);
  }

  ProjectText[] byProject(TenantId tenantId, TranslationProjectId projectId) {
    return repos.texts.findByProject(tenantId, projectId);
  }

  UsecaseResult translate(TenantId tenantId, ProjectTextId id, UserId actor) {
    return guarded(() {
      auto t = require(tenantId, id);
      auto project = requireProject(tenantId, t.projectId);
      ensureWritable(project);
      ProjectRun run;
      service.translateText(t, project, project.targetLanguages, true, run);
      t.update(actor);
      repo.update(t);
      service.refresh(tenantId, project.id);
      publish(t, "translated");
      return succeeded(t.id.value, "Text '%s': %d translation(s), status %s".format(t.name, run.translations,
          enumText(t.status)));
    });
  }

  UsecaseResult setTranslation(TenantId tenantId, ProjectTextId id, string language, string text, UserId actor) {
    return guarded(() {
      auto t = require(tenantId, id);
      auto project = requireProject(tenantId, t.projectId);
      ensureWritable(project);
      auto lang = requireLanguage("Language", language);
      validate(project.targetLanguages.canFind(lang), "'" ~ lang ~ "' is not a target language of '" ~ project.name ~ "'");
      validate(text.strip.length > 0, "Translation text is required");
      auto existing = translationFor(t.translations, lang);
      TextTranslation tr;
      tr.language = lang;
      tr.text = text;
      tr.provider = existing.text.length ? existing.provider : TranslationProvider.companyMltr;
      tr.qualityScore = 100;
      tr.reviewed = true;
      tr.translatedAt = nowStdTime();
      ProjectTranslationService.setTranslation(t, tr);
      t.status = textStatusOf(t.translations, project.targetLanguages);
      t.update(actor);
      repo.update(t);
      service.refresh(tenantId, project.id);
      publish(t, "updated");
      return succeeded(t.id.value, "Text '" ~ t.name ~ "' translated into " ~ lang);
    });
  }

  UsecaseResult review(TenantId tenantId, ProjectTextId id, string language, UserId actor) {
    return guarded(() {
      auto t = require(tenantId, id);
      auto project = requireProject(tenantId, t.projectId);
      ensureWritable(project);
      auto lang = language.strip.length ? normalizeLanguage(language) : "";
      int count;
      foreach (ref tr; t.translations)
        if ((lang.length == 0 || tr.language == lang) && tr.text.length > 0 && !tr.reviewed) {
          tr.reviewed = true;
          count++;
        }
      ensureState(count > 0, "Text '" ~ t.name ~ "' has no unreviewed translation" ~ (lang.length ? " for " ~ lang : ""));
      t.status = textStatusOf(t.translations, project.targetLanguages);
      t.update(actor);
      repo.update(t);
      publish(t, "reviewed");
      return succeeded(t.id.value, "Text '%s': %d translation(s) reviewed".format(t.name, count));
    });
  }
}
