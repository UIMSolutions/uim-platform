/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.usecases.translate;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Synchronous translation (nothing is stored).
interface IPerformTranslationUseCase {
  /// Translate software / UI texts (one result per input text).
  TranslateTextsResult translateTexts(TranslateTextsRequest request);
  /// Translate a document's text content inline.
  DocumentTranslationResult translateDocument(TranslateDocumentRequest request);
}
