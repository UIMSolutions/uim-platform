/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.ports.usecases.translations;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Use case for synchronous software text translation and document translation.
interface IPerformTranslationUseCase {

    /// Translate an array of software / UI texts synchronously.
    /// Returns one translated item per input text.
    Json translateTexts(TranslateTextRequest r);

    /// Translate a document or text synchronously — returns translated content inline.
    Json translateDocument(TranslateDocumentRequest r);

    /// Returns the list of supported BCP-47 language codes.
    string[] supportedLanguages();
    
}
