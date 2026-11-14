/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Translation of project texts and progress bookkeeping of projects.
module uim.platform.translation.application.services.project_translation;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Outcome of translating texts of a project.
struct ProjectRun {
  int texts; /// texts examined
  int translations; /// translations created or replaced
  int glossaryHits;
  int[] scores;
  long characters;
}

class ProjectTranslationService {
  protected TranslationRepositories repos;
  protected Translator translator;

  this(TranslationRepositories repos, Translator translator) {
    this.repos = repos;
    this.translator = translator;
  }

  /// Translate `text` into `languages`. Missing translations are created;
  /// existing machine translations are replaced only if `force`; reviewed
  /// translations are never replaced.
  void translateText(ref ProjectText text, const TranslationProject project, const string[] languages,
      bool force, ref ProjectRun run) {
    run.texts++;
    foreach (lang; languages) {
      auto existing = translationFor(text.translations, lang);
      if (existing.reviewed || (existing.text.length > 0 && !force))
        continue;
      auto r = translator.translate(text.tenantId, text.sourceText, project.sourceLanguage, lang,
        project.provider, project.domainName, text.textType, text.maxLength);
      TextTranslation t;
      t.language = lang;
      t.text = r.translatedText;
      t.provider = project.provider;
      t.qualityScore = r.qualityScore;
      t.glossaryHits = r.glossaryHits;
      t.translatedAt = nowStdTime();
      setTranslation(text, t);
      run.translations++;
      run.glossaryHits += r.glossaryHits;
      run.scores ~= r.qualityScore;
      run.characters += text.sourceText.length;
    }
    text.status = textStatusOf(text.translations, project.targetLanguages);
  }

  /// Translate every text of a project. `languages` empty = every target language.
  ProjectRun translateProject(TranslationProject project, const string[] languages, bool force, UserId actor) {
    ProjectRun run;
    auto langs = languages.length ? languages : project.targetLanguages;
    foreach (text; repos.texts.findByProject(project.tenantId, project.id)) {
      auto before = run.translations;
      translateText(text, project, langs, force, run);
      if (run.translations > before) {
        text.update(actor);
        repos.texts.update(text);
      }
    }
    if (project.status == ProjectStatus.draft)
      project.status = ProjectStatus.active;
    project.lastTranslatedAt = nowStdTime();
    project.update(actor);
    repos.projects.update(project);
    refresh(project.tenantId, project.id);
    return run;
  }

  /// Recompute text count, completion and status of a project from its texts.
  void refresh(TenantId tenantId, TranslationProjectId projectId) {
    auto project = repos.projects.findById(tenantId, projectId);
    if (project.isNull)
      return;
    auto texts = repos.texts.findByProject(tenantId, projectId);
    project.textCount = cast(int) texts.length;
    project.completionPercent = completionOf(texts, project.targetLanguages);
    project.status = progressStatus(project.status, project.completionPercent, project.textCount);
    repos.projects.update(project);
  }

  /// Recompute the status of every text after the target languages changed.
  void restatus(TranslationProject project) {
    foreach (text; repos.texts.findByProject(project.tenantId, project.id)) {
      auto status = textStatusOf(text.translations, project.targetLanguages);
      if (status != text.status) {
        text.status = status;
        repos.texts.update(text);
      }
    }
  }

  /// Insert or replace the translation of t.language.
  static void setTranslation(ref ProjectText text, TextTranslation t) {
    foreach (ref existing; text.translations)
      if (existing.language == t.language) {
        existing = t;
        return;
      }
    text.translations ~= t;
  }
}
