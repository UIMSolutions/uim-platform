/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.ports.usecases.glossary_entries;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

interface IManageGlossaryEntriesUseCase {

    UsecaseResult createEntry(CreateGlossaryEntryRequest r);

    GlossaryEntry[] listEntries(TenantId tenantId);

    GlossaryEntry getEntry(TenantId tenantId, GlossaryEntryId id);

    UsecaseResult updateEntry(UpdateGlossaryEntryRequest r);

    UsecaseResult deleteEntry(TenantId tenantId, GlossaryEntryId id);
}
