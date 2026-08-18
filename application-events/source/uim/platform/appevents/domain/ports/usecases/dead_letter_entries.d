/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.ports.usecases.dead_letter_entries;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

interface ManageDeadLetterEntriesUseCase {

    DeadLetterEntry getDeadLetterEntry(TenantId tenantId, DeadLetterEntryId id);
    DeadLetterEntry[] listDeadLetterEntries(TenantId tenantId);
    DeadLetterEntry[] listByStatus(TenantId tenantId, DeadLetterStatus status);
    UsecaseResult createDeadLetterEntry(DeadLetterEntryDTO dto);
    UsecaseResult deleteDeadLetterEntry(TenantId tenantId, DeadLetterEntryId id);

}
