/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects embedded in the aggregates (exchanged as OData complex types)
/// and the reference data of the service (languages, domains, text types).
module uim.platform.translation.domain.types.values;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// The translation of a project text into one target language.
struct TextTranslation {
  string language; /// BCP-47 tag, e.g. "de"
  string text;
  TranslationProvider provider = TranslationProvider.machineMt;
  int qualityScore; /// 0–100
  int glossaryHits; /// glossary terms enforced in this translation
  bool reviewed; /// confirmed by a human translator
  long translatedAt;
}

/// The translation of `language` in a list of translations (TextTranslation.init if missing).
TextTranslation translationFor(const TextTranslation[] translations, string language) {
  foreach (t; translations)
    if (t.language == language)
      return t;
  return TextTranslation.init;
}

/// A supported language (reference data, read-only OData entity set).
struct Language {
  string id; /// BCP-47 primary tag, e.g. "de"
  string name; /// English name
  string nativeName;
  bool rightToLeft;
}

/// A translation domain (subject area that selects terminology).
struct TranslationDomain {
  string id; /// e.g. "FI"
  string name; /// e.g. "Finance"
}

/// A text type: what kind of software text is translated.
struct TextTypeInfo {
  string id; /// TextType name, e.g. "uiText"
  string name;
  string description;
  int recommendedMaxLength; /// 0 = no recommendation
}

/// Limits of the translation service (configured per deployment).
struct TranslationPolicy {
  /// Maximum length of one text in a text translation request.
  int maxTextLength = 5000;
  /// Maximum number of texts per text translation request.
  int maxBatchSize = 100;
  /// Maximum length of a document (characters).
  int maxDocumentLength = 1_000_000;
  /// Provider used when a request does not name one.
  TranslationProvider defaultProvider = TranslationProvider.machineMt;
}

///
unittest {
  auto list = [TextTranslation("de", "Speichern"), TextTranslation("fr", "Enregistrer")];
  assert(translationFor(list, "fr").text == "Enregistrer");
  assert(translationFor(list, "es").language.length == 0);
}
