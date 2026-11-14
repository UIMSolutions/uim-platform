/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Language tags (BCP-47) and the catalogue of supported languages.
module uim.platform.translation.domain.services.languages;

import std.ascii : isAlpha, isAlphaNum;
import std.string : toLower, toUpper, split, join;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// All supported languages (primary subtags).
immutable Language[] supportedLanguages = [
  Language("af", "Afrikaans", "Afrikaans"), Language("ar", "Arabic", "العربية", true),
  Language("bg", "Bulgarian", "Български"), Language("bn", "Bengali", "বাংলা"),
  Language("ca", "Catalan", "Català"), Language("cs", "Czech", "Čeština"),
  Language("da", "Danish", "Dansk"), Language("de", "German", "Deutsch"),
  Language("el", "Greek", "Ελληνικά"), Language("en", "English", "English"),
  Language("es", "Spanish", "Español"), Language("et", "Estonian", "Eesti"),
  Language("eu", "Basque", "Euskara"), Language("fa", "Persian", "فارسی", true),
  Language("fi", "Finnish", "Suomi"), Language("fr", "French", "Français"),
  Language("gl", "Galician", "Galego"), Language("he", "Hebrew", "עברית", true),
  Language("hi", "Hindi", "हिन्दी"), Language("hr", "Croatian", "Hrvatski"),
  Language("hu", "Hungarian", "Magyar"), Language("id", "Indonesian", "Bahasa Indonesia"),
  Language("it", "Italian", "Italiano"), Language("ja", "Japanese", "日本語"),
  Language("ko", "Korean", "한국어"), Language("lt", "Lithuanian", "Lietuvių"),
  Language("lv", "Latvian", "Latviešu"), Language("ms", "Malay", "Bahasa Melayu"),
  Language("nb", "Norwegian Bokmål", "Norsk bokmål"), Language("nl", "Dutch", "Nederlands"),
  Language("pl", "Polish", "Polski"), Language("pt", "Portuguese", "Português"),
  Language("ro", "Romanian", "Română"), Language("ru", "Russian", "Русский"),
  Language("sk", "Slovak", "Slovenčina"), Language("sl", "Slovenian", "Slovenščina"),
  Language("sv", "Swedish", "Svenska"), Language("sw", "Swahili", "Kiswahili"),
  Language("th", "Thai", "ไทย"), Language("tr", "Turkish", "Türkçe"),
  Language("uk", "Ukrainian", "Українська"), Language("ur", "Urdu", "اردو", true),
  Language("vi", "Vietnamese", "Tiếng Việt"), Language("zh", "Chinese", "中文"),
];

/// Canonical form of a language tag: "DE" → "de", "de_de" → "de-DE",
/// "zh-hant-tw" → "zh-Hant-TW". Invalid tags are returned trimmed.
string normalizeLanguage(string tag) {
  auto parts = tag.strip.replace("_", "-").split("-");
  if (parts.length == 0 || parts[0].length == 0)
    return "";
  string[] result = [parts[0].toLower];
  foreach (p; parts[1 .. $]) {
    if (p.length == 2 && p[0].isAlpha)
      result ~= p.toUpper; // region
    else if (p.length == 4)
      result ~= p[0 .. 1].toUpper ~ p[1 .. $].toLower; // script
    else
      result ~= p.toLower;
  }
  return result.join("-");
}

/// The primary subtag ("de-CH" → "de").
string primaryLanguage(string tag) {
  auto t = normalizeLanguage(tag);
  auto dash = t.indexOf('-');
  return dash < 0 ? t : t[0 .. dash];
}

/// True if the primary subtag of `tag` is a supported language.
bool isSupportedLanguage(string tag) {
  auto primary = primaryLanguage(tag);
  return supportedLanguages.any!(l => l.id == primary);
}

/// The catalogue entry of a tag (Language.init if unsupported).
Language languageOf(string tag) {
  auto primary = primaryLanguage(tag);
  foreach (l; supportedLanguages)
    if (l.id == primary)
      return l;
  return Language.init;
}

/// Validate and normalize one language tag.
string requireLanguage(string what, string tag) {
  auto t = normalizeLanguage(tag);
  validate(t.length > 0, what ~ " is required");
  foreach (c; t)
    validate(isAlphaNum(c) || c == '-', what ~ " '" ~ tag ~ "' is not a BCP-47 language tag");
  validate(isSupportedLanguage(t), what ~ " '" ~ tag ~ "' is not supported");
  return t;
}

/// Validate a source/target pair: both supported and different.
void validateLanguagePair(string sourceLanguage, string targetLanguage) {
  validate(normalizeLanguage(sourceLanguage) != normalizeLanguage(targetLanguage),
    "Source and target language must differ (" ~ sourceLanguage ~ ")");
}

/// Validate and normalize the target languages of a project: at least one,
/// supported, unique and different from the source language.
string[] requireTargetLanguages(string sourceLanguage, const string[] targets) {
  validate(targets.length > 0, "At least one target language is required");
  string[] result;
  foreach (t; targets) {
    auto tag = requireLanguage("Target language", t);
    validateLanguagePair(sourceLanguage, tag);
    validate(!result.canFind(tag), "Target language '" ~ tag ~ "' is listed twice");
    result ~= tag;
  }
  return result;
}

///
unittest {
  assert(normalizeLanguage(" DE ") == "de");
  assert(normalizeLanguage("de_ch") == "de-CH");
  assert(normalizeLanguage("zh-hant-tw") == "zh-Hant-TW");
  assert(primaryLanguage("pt-BR") == "pt");
  assert(isSupportedLanguage("pt-BR") && !isSupportedLanguage("xx"));
  assert(languageOf("ar").rightToLeft);
  assert(requireLanguage("Target", "FR") == "fr");
  assert(requireTargetLanguages("en", ["DE", "fr"]) == ["de", "fr"]);

  bool failed(void delegate() @safe f) {
    try
      f();
    catch (TranslationValidationException)
      return true;
    return false;
  }

  assert(failed(() { requireLanguage("Target", "klingon"); }));
  assert(failed(() { requireTargetLanguages("en", ["de", "de"]); }));
  assert(failed(() { requireTargetLanguages("en", ["en"]); }));
  assert(failed(() { requireTargetLanguages("en", []); }));
}
