/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.services.catalog;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Reference data: languages, domains, text types and providers.
class TranslationCatalogService : ITranslationCatalogService {
  protected ITranslationProviderGateway gateway;

  this(ITranslationProviderGateway gateway) {
    this.gateway = gateway;
  }

  Language[] languages() {
    return supportedLanguages.dup;
  }

  TranslationDomain[] domains() {
    return translationDomains.dup;
  }

  TextTypeInfo[] textTypes() {
    return uim.platform.translation.domain.services.catalogs.textTypes.dup;
  }

  ProviderInfo[] providers() {
    static immutable string[3][] info = [
      ["mltr", "SAP MLTR", "Multilingual text repository: verified translations of SAP terminology"],
      ["machineMt", "Neural MT", "Neural machine translation"],
      ["companyMltr", "Company MLTR", "Company glossary first (optional entries applied), then machine translation"],
      ["llm", "LLM", "Large language model via the generative AI hub"],
    ];
    ProviderInfo[] result;
    foreach (i; info)
      result ~= ProviderInfo(i[0], i[1], i[2], gateway.available(parseEnum!TranslationProvider(i[0],
          TranslationProvider.machineMt)));
    return result;
  }
}
