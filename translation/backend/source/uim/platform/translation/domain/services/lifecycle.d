/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// State rules of projects, project texts and jobs.
module uim.platform.translation.domain.services.lifecycle;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Status of a text across the target languages of its project.
TextStatus textStatusOf(const TextTranslation[] translations, const string[] targetLanguages) {
  if (targetLanguages.length == 0)
    return TextStatus.untranslated;
  size_t done, reviewed;
  foreach (lang; targetLanguages) {
    auto t = translationFor(translations, lang);
    if (t.text.length > 0) {
      done++;
      if (t.reviewed)
        reviewed++;
    }
  }
  if (done == 0)
    return TextStatus.untranslated;
  if (done < targetLanguages.length)
    return TextStatus.partial;
  return reviewed == targetLanguages.length ? TextStatus.reviewed : TextStatus.translated;
}

/// Translated (text, target language) pairs in percent.
int completionOf(const ProjectText[] texts, const string[] targetLanguages) {
  auto total = texts.length * targetLanguages.length;
  if (total == 0)
    return 0;
  size_t done;
  foreach (text; texts)
    foreach (lang; targetLanguages)
      if (translationFor(text.translations, lang).text.length > 0)
        done++;
  return cast(int)(done * 100 / total);
}

/// Project status after its progress changed. Draft and archived projects keep their status.
ProjectStatus progressStatus(ProjectStatus current, int completionPercent, int textCount) {
  if (current == ProjectStatus.archived || current == ProjectStatus.draft)
    return current;
  if (textCount > 0 && completionPercent >= 100)
    return ProjectStatus.completed;
  if (completionPercent > 0)
    return ProjectStatus.inProgress;
  return ProjectStatus.active;
}

/// Archived projects are read-only.
void ensureWritable(const TranslationProject project) {
  ensureState(project.status != ProjectStatus.archived,
    "Translation project '" ~ project.name ~ "' is archived");
}

/// Only pending jobs can be processed.
void ensureProcessable(const TranslationJob job) {
  ensureState(job.status == JobStatus.pending,
    "Job '" ~ job.name ~ "' is " ~ enumText(job.status) ~ ", only pending jobs can be processed");
}

/// Finished jobs cannot be cancelled.
void ensureCancellable(const TranslationJob job) {
  ensureState(job.status == JobStatus.pending || job.status == JobStatus.processing,
    "Job '" ~ job.name ~ "' is " ~ enumText(job.status) ~ " and cannot be cancelled");
}

/// Failed and cancelled jobs can be retried.
void ensureRetryable(const TranslationJob job) {
  ensureState(job.status == JobStatus.failed || job.status == JobStatus.cancelled,
    "Job '" ~ job.name ~ "' is " ~ enumText(job.status) ~ ", only failed or cancelled jobs can be retried");
}

/// Running jobs cannot be deleted.
void ensureRemovable(const TranslationJob job) {
  ensureState(job.status != JobStatus.processing, "Job '" ~ job.name ~ "' is being processed");
}

///
unittest {
  auto langs = ["de", "fr"];
  assert(textStatusOf([], langs) == TextStatus.untranslated);
  assert(textStatusOf([TextTranslation("de", "x")], langs) == TextStatus.partial);
  auto both = [TextTranslation("de", "x"), TextTranslation("fr", "y")];
  assert(textStatusOf(both, langs) == TextStatus.translated);
  both[0].reviewed = both[1].reviewed = true;
  assert(textStatusOf(both, langs) == TextStatus.reviewed);

  ProjectText a, b;
  a.translations = both;
  assert(completionOf([a, b], langs) == 50);
  assert(progressStatus(ProjectStatus.active, 50, 2) == ProjectStatus.inProgress);
  assert(progressStatus(ProjectStatus.inProgress, 100, 2) == ProjectStatus.completed);
  assert(progressStatus(ProjectStatus.completed, 0, 0) == ProjectStatus.active);
  assert(progressStatus(ProjectStatus.draft, 100, 2) == ProjectStatus.draft);
}
