/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.services.catalog;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Reference data of the service (value helps, `languages` command).
interface ITranslationCatalogService {
  Language[] languages();
  TranslationDomain[] domains();
  TextTypeInfo[] textTypes();
  /// Providers and whether they are available.
  ProviderInfo[] providers();
}
