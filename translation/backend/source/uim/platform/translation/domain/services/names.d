/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Naming rules of projects, text keys and derived display names.
module uim.platform.translation.domain.services.names;

import std.ascii : isAlphaNum;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// A display name (project): 1–120 characters, no surrounding blanks.
void validateDisplayName(string kind, string name) {
  validate(name.strip.length > 0, kind ~ " name is required");
  validate(name.length <= 120, kind ~ " name must not exceed 120 characters");
  validate(name == name.strip, kind ~ " name must not start or end with blanks");
}

/// A text key: 1–120 letters, digits, '_', '.', '-' (e.g. "BUTTON_SAVE", "app.title").
void validateTextKey(string key) {
  validate(key.length > 0, "Text key is required");
  validate(key.length <= 120, "Text key must not exceed 120 characters");
  foreach (c; key)
    validate(isAlphaNum(c) || c == '_' || c == '.' || c == '-',
      "Text key may only contain letters, digits, '_', '.' and '-' (got '" ~ key ~ "')");
}

/// An http(s) or git/ssh URL of a Git repository.
bool isRepositoryUrl(string url) pure {
  return (url.startsWith("https://") && url.length > 8) || (url.startsWith("http://") && url.length > 7)
    || (url.startsWith("git@") && url.canFind(":")) || url.startsWith("ssh://");
}

/// "invoice (en→de)".
string glossaryEntryName(string sourceTerm, string sourceLanguage, string targetLanguage) {
  return sourceTerm ~ " (" ~ sourceLanguage ~ "→" ~ targetLanguage ~ ")";
}

/// "document en→de", "software <project> en→*".
string jobName(JobType type, string sourceLanguage, string targetLanguage, string projectName = "") {
  auto pair = sourceLanguage ~ "→" ~ (targetLanguage.length ? targetLanguage : "*");
  return enumText(type) ~ (projectName.length ? " " ~ projectName : "") ~ " " ~ pair;
}

///
unittest {
  bool failed(void delegate() @safe f) {
    try
      f();
    catch (TranslationValidationException)
      return true;
    return false;
  }

  validateTextKey("BUTTON_SAVE");
  validateTextKey("app.title-1");
  assert(failed(() => validateTextKey("BUTTON SAVE")));
  assert(failed(() => validateDisplayName("Project", " x")));
  assert(isRepositoryUrl("https://github.com/acme/app.git") && isRepositoryUrl("git@github.com:acme/app.git"));
  assert(!isRepositoryUrl("ftp://x"));
  assert(glossaryEntryName("invoice", "en", "de") == "invoice (en→de)");
  assert(jobName(JobType.software, "en", "", "Shop") == "software Shop en→*");
}
