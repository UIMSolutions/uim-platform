/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.gateways.provider;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// What a translation engine returns for one text.
struct ProviderTranslation {
  string text;
  int qualityScore; /// engine estimate 0–100
}

/// Driven port: a translation engine (SAP MLTR, neural MT, LLM via the
/// generative AI hub). Placeholders "⟦n⟧" in the text must be kept unchanged.
interface ITranslationProviderGateway {
  ProviderTranslation translate(string text, string sourceLanguage, string targetLanguage,
    TranslationProvider provider, string domainName, TextType textType);

  /// False if the engine is not configured / reachable.
  bool available(TranslationProvider provider);
}
