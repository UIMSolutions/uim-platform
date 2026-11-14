/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.enumerations.translations;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Translation engine / provider.
enum TranslationProvider {
  mltr, /// SAP multilingual text repository (verified translations)
  machineMt, /// neural machine translation
  companyMltr, /// company-specific multilingual text repository (glossary first)
  llm, /// large language model (generative AI hub)
}

/// Quality rating derived from the quality score.
enum QualityLevel {
  excellent, /// ≥ 90
  good, /// ≥ 75
  adequate, /// ≥ 60
  poor, /// < 60
  unknown, /// not translated yet
}
