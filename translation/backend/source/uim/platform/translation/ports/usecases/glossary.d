/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.ports.usecases.glossary;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Maintain the company glossary (company MLTR).
interface IManageGlossaryUseCase : IManageResource!(GlossaryEntry, GlossaryEntryId,
    CreateGlossaryEntryRequest, UpdateGlossaryEntryRequest) {
  /// Entries of a language pair.
  GlossaryEntry[] byLanguagePair(TenantId tenantId, string sourceLanguage, string targetLanguage);
}
