/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.translate;

import std.range : walkLength;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Interactor: synchronous text and document translation (nothing is stored).
/// Business errors are thrown as TranslationException.
class PerformTranslationUseCase : IPerformTranslationUseCase {
  protected Translator translator;
  protected ITranslationEventPublisher publisher;

  this(Translator translator, ITranslationEventPublisher publisher) {
    this.translator = translator;
    this.publisher = publisher;
  }

  TranslateTextsResult translateTexts(TranslateTextsRequest r) {
    auto limits = translator.limits;
    validate(r.texts.length > 0, "No texts provided");
    validate(r.texts.length <= limits.maxBatchSize, "At most %d texts per request".format(limits.maxBatchSize));
    foreach (t; r.texts)
      validate(t.walkLength <= limits.maxTextLength, "Texts must not exceed %d characters".format(limits.maxTextLength));

    TranslateTextsResult result;
    result.sourceLanguage = requireLanguage("sourceLanguage", r.sourceLanguage);
    result.targetLanguage = requireLanguage("targetLanguage", r.targetLanguage);
    validateLanguagePair(result.sourceLanguage, result.targetLanguage);
    result.provider = translator.resolveProvider(r.provider);
    result.domainName = requireDomain(r.domainName);
    result.textType = translator.resolveTextType(r.textType);

    int[] scores;
    foreach (t; r.texts) {
      auto tr = translator.translate(r.tenantId, t, result.sourceLanguage, result.targetLanguage, result.provider,
        result.domainName, result.textType);
      result.translations ~= tr;
      result.glossaryHits += tr.glossaryHits;
      scores ~= tr.qualityScore;
    }
    result.count = cast(int) result.translations.length;
    result.averageQuality = averageQuality(scores);
    publisher.publish("translation.texts.translated", Json.emptyObject.set("tenantId", r.tenantId.value)
        .set("count", result.count).set("targetLanguage", result.targetLanguage));
    return result;
  }

  DocumentTranslationResult translateDocument(TranslateDocumentRequest r) {
    validate(r.content.strip.length > 0, "Content is required");
    auto source = requireLanguage("sourceLanguage", r.sourceLanguage);
    auto target = requireLanguage("targetLanguage", r.targetLanguage);
    validateLanguagePair(source, target);
    auto result = translator.translateDocument(r.tenantId, r.content, r.contentType, source, target,
      translator.resolveProvider(r.provider), requireDomain(r.domainName));
    publisher.publish("translation.document.translated", Json.emptyObject.set("tenantId", r.tenantId.value)
        .set("characters", result.characterCount).set("targetLanguage", target));
    return result;
  }
}
