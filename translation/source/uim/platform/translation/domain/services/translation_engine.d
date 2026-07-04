/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.services.translation_engine;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Result of a single text translation
struct TranslationResult {
    string sourceText;
    string translatedText;
    string sourceLanguage;
    string targetLanguage;
    TranslationProvider provider;
    /// Quality score 0–100
    int qualityScore;
    QualityLevel qualityLevel;
}

/// Domain service that performs mock/in-process text translation.
/// In a production deployment this would delegate to an actual MT engine
/// or the SAP Multilingual Text Repository via an HTTP adapter.
class TranslationEngine {
    /// Translate a single text string.
    TranslationResult translate(
        string text,
        string sourceLang,
        string targetLang,
        TranslationProvider provider
    ) {
        TranslationResult r;
        r.sourceText = text;
        r.sourceLanguage = sourceLang;
        r.targetLanguage = targetLang;
        r.provider = provider;

        // --- Mock translation logic ---
        // A real implementation would call an HTTP adapter (MT engine, MLTR).
        final switch (provider) {
            case TranslationProvider.mltr:
                r.translatedText = "[MLTR:" ~ targetLang ~ "] " ~ text;
                r.qualityScore = 92;
                r.qualityLevel = QualityLevel.excellent;
                break;
            case TranslationProvider.machineMt:
                r.translatedText = "[MT:" ~ targetLang ~ "] " ~ text;
                r.qualityScore = 75;
                r.qualityLevel = QualityLevel.good;
                break;
            case TranslationProvider.companyMltr:
                r.translatedText = "[CMLTR:" ~ targetLang ~ "] " ~ text;
                r.qualityScore = 88;
                r.qualityLevel = QualityLevel.excellent;
                break;
            case TranslationProvider.llm:
                r.translatedText = "[LLM:" ~ targetLang ~ "] " ~ text;
                r.qualityScore = 80;
                r.qualityLevel = QualityLevel.good;
                break;
        }
        return r;
    }

    /// Translate multiple texts in a batch.
    TranslationResult[] translateBatch(
        string[] texts,
        string sourceLang,
        string targetLang,
        TranslationProvider provider
    ) {
        TranslationResult[] results;
        foreach (t; texts)
            results ~= translate(t, sourceLang, targetLang, provider);
        return results;
    }

    /// Returns whether the given source→target language pair is supported.
    bool supportsLanguagePair(string sourceLang, string targetLang) {
        import std.algorithm : canFind;
        return supportedLanguages.canFind(sourceLang) && supportedLanguages.canFind(targetLang);
    }

    /// All supported BCP-47 language codes.
    static immutable string[] supportedLanguages = [
        "en", "de", "fr", "es", "it", "pt", "nl", "pl", "sv", "da",
        "nb", "fi", "cs", "sk", "hu", "ro", "bg", "hr", "sl", "et",
        "lv", "lt", "el", "tr", "ru", "uk", "ar", "he", "zh", "ja",
        "ko", "th", "vi", "id", "ms", "hi", "bn", "ur", "fa", "sw",
        "af", "ca", "eu", "gl",
    ];
}
