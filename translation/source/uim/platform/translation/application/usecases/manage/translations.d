/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.manage.translations;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Use case for synchronous software text translation and document translation.
class PerformTranslationUseCase {
    private TranslationEngine engine;

    this(TranslationEngine engine) {
        this.engine = engine;
    }

    /// Translate an array of software / UI texts synchronously.
    /// Returns one translated item per input text.
    Json translateTexts(TranslateTextRequest r) {
        if (r.texts.length == 0) {
            return Json.emptyObject
                .set("status", "error")
                .set("message", "No texts provided");
        }
        if (r.sourceLanguage.length == 0 || r.targetLanguage.length == 0) {
            return Json.emptyObject
                .set("status", "error")
                .set("message", "sourceLanguage and targetLanguage are required");
        }

        TranslationProvider prov = TranslationProvider.machineMt;
        if (r.provider.length > 0) {
            try { prov = r.provider.to!TranslationProvider; }
            catch (Exception) {}
        }

        auto results = engine.translateBatch(r.texts, r.sourceLanguage, r.targetLanguage, prov);

        auto arr = Json.emptyArray;
        foreach (res; results) {
            arr ~= Json.emptyObject
                .set("sourceText", res.sourceText)
                .set("translatedText", res.translatedText)
                .set("sourceLanguage", res.sourceLanguage)
                .set("targetLanguage", res.targetLanguage)
                .set("provider", res.provider.to!string)
                .set("qualityScore", res.qualityScore)
                .set("qualityLevel", res.qualityLevel.to!string);
        }

        return Json.emptyObject
            .set("translations", arr)
            .set("count", results.length)
            .set("sourceLanguage", r.sourceLanguage)
            .set("targetLanguage", r.targetLanguage);
    }

    /// Translate a document or text synchronously — returns translated content inline.
    Json translateDocument(TranslateDocumentRequest r) {
        if (r.content.length == 0)
            return errorResponse("Content is required", 400);

        TranslationProvider prov = TranslationProvider.machineMt;
        if (r.provider.length > 0) {
            try { prov = r.provider.to!TranslationProvider; }
            catch (Exception) {}
        }

        auto result = engine.translate(r.content, r.sourceLanguage, r.targetLanguage, prov);

        return Json.emptyObject
            .set("translatedContent", result.translatedText)
            .set("sourceLanguage", result.sourceLanguage)
            .set("targetLanguage", result.targetLanguage)
            .set("provider", result.provider.to!string)
            .set("qualityScore", result.qualityScore)
            .set("qualityLevel", result.qualityLevel.to!string)
            .set("contentType", r.contentType);
    }

    /// Returns the list of supported BCP-47 language codes.
    string[] supportedLanguages() {
        string[] langs;
        foreach (l; TranslationEngine.supportedLanguages)
            langs ~= l;
        return langs;
    }
}
