/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The translation pipeline shared by synchronous requests, project runs and
/// jobs: glossary protection → provider → glossary restore → quality estimate.
module uim.platform.translation.application.services.translator;

import std.range : walkLength;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

class Translator {
  protected ITranslationProviderGateway gateway;
  protected IGlossaryRepository glossary;
  protected TranslationPolicy policy;

  this(ITranslationProviderGateway gateway, IGlossaryRepository glossary, TranslationPolicy policy) {
    this.gateway = gateway;
    this.glossary = glossary;
    this.policy = policy;
  }

  TranslationPolicy limits() const {
    return policy;
  }

  /// A provider by name ("" = configured default). Unknown names are a validation error.
  TranslationProvider resolveProvider(string name) {
    if (name.strip.length == 0)
      return policy.defaultProvider;
    validate(isEnumText!TranslationProvider(name), "Unknown provider '" ~ name ~ "' (" ~ enumTexts!TranslationProvider.join(", ") ~ ")");
    return parseEnum!TranslationProvider(name, policy.defaultProvider);
  }

  /// A text type by name ("" = uiText).
  TextType resolveTextType(string name) {
    if (name.strip.length == 0)
      return TextType.uiText;
    validate(isEnumText!TextType(name), "Unknown text type '" ~ name ~ "'");
    return parseEnum!TextType(name, TextType.uiText);
  }

  /// Translate one text. `maxLength` (0 = text type recommendation) flags truncation risks;
  /// an explicit maxLength also lowers the quality score when exceeded.
  TranslatedText translate(TenantId tenantId, string text, string sourceLanguage, string targetLanguage,
      TranslationProvider provider, string domainName, TextType textType, int maxLength = 0) {
    ensureState(gateway.available(provider), "Translation provider '" ~ enumText(provider) ~ "' is not available");
    return translateWith(text, sourceLanguage, targetLanguage, provider, domainName, textType, maxLength,
      applicableEntries(glossary.findByLanguagePair(tenantId, sourceLanguage, targetLanguage),
        sourceLanguage, targetLanguage, domainName, provider));
  }

  protected TranslatedText translateWith(string text, string sourceLanguage, string targetLanguage,
      TranslationProvider provider, string domainName, TextType textType, int maxLength, const GlossaryEntry[] entries) {
    TranslatedText r;
    r.sourceText = text;
    if (text.strip.length == 0) {
      r.translatedText = text;
      return r;
    }
    auto shielded = protectTerms(text, entries);
    auto engine = gateway.translate(shielded.text, sourceLanguage, targetLanguage, provider, domainName, textType);
    int hits;
    r.translatedText = restoreTerms(engine.text, shielded.targets, hits);
    r.glossaryHits = hits;
    auto length = r.translatedText.walkLength;
    r.qualityScore = adjustQuality(engine.qualityScore, hits, length, maxLength);
    r.qualityLevel = qualityLevelOf(r.qualityScore);
    auto limit = maxLength > 0 ? maxLength : textTypeInfo(textType).recommendedMaxLength;
    r.truncationRisk = limit > 0 && length > limit;
    return r;
  }

  /// Translate a document. Structure is kept: application/json translates
  /// string values only, text/x-java-properties translates values only, every
  /// other type is translated line by line.
  DocumentTranslationResult translateDocument(TenantId tenantId, string content, string contentType,
      string sourceLanguage, string targetLanguage, TranslationProvider provider, string domainName) {
    ensureState(gateway.available(provider), "Translation provider '" ~ enumText(provider) ~ "' is not available");
    validate(content.walkLength <= policy.maxDocumentLength,
      "Document exceeds " ~ policy.maxDocumentLength.to!string ~ " characters");
    auto entries = applicableEntries(glossary.findByLanguagePair(tenantId, sourceLanguage, targetLanguage),
      sourceLanguage, targetLanguage, domainName, provider);

    int[] scores;
    int hits;
    string one(string s) {
      auto t = translateWith(s, sourceLanguage, targetLanguage, provider, domainName, TextType.documentation, 0, entries);
      if (s.strip.length > 0)
        scores ~= t.qualityScore;
      hits += t.glossaryHits;
      return t.translatedText;
    }

    DocumentTranslationResult r;
    r.sourceLanguage = sourceLanguage;
    r.targetLanguage = targetLanguage;
    r.provider = provider;
    r.contentType = contentType.length ? contentType : "text/plain";
    r.characterCount = cast(int) content.walkLength;

    auto type = r.contentType.toLower;
    if (type.canFind("json")) {
      Json doc;
      try
        doc = parseJsonString(content);
      catch (Exception e)
        throw new TranslationValidationException("Content is not valid JSON: " ~ e.msg);
      r.translatedContent = translateJson(doc, &one).toPrettyString;
    } else if (type.canFind("properties")) {
      string[] lines;
      foreach (line; content.split("\n")) {
        auto trimmed = line.strip;
        auto eq = line.indexOf('=');
        if (trimmed.length == 0 || trimmed[0] == '#' || trimmed[0] == '!' || eq < 0)
          lines ~= line;
        else
          lines ~= line[0 .. eq + 1] ~ one(line[eq + 1 .. $]);
      }
      r.translatedContent = lines.join("\n");
    } else {
      string[] lines;
      foreach (line; content.split("\n"))
        lines ~= one(line);
      r.translatedContent = lines.join("\n");
    }
    r.qualityScore = averageQuality(scores);
    r.qualityLevel = qualityLevelOf(r.qualityScore);
    r.glossaryHits = hits;
    return r;
  }

  protected static Json translateJson(Json node, scope string delegate(string) @safe one) {
    switch (node.type) {
    case Json.Type.string:
      return Json(one(node.get!string));
    case Json.Type.array:
      auto arr = Json.emptyArray;
      foreach (item; node.get!(Json[]))
        arr ~= translateJson(item, one);
      return arr;
    case Json.Type.object:
      auto obj = Json.emptyObject;
      foreach (k, v; node.get!(Json[string]))
        obj[k] = translateJson(v, one);
      return obj;
    default:
      return node;
    }
  }
}
