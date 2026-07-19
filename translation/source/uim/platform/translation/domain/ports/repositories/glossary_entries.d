/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.ports.repositories.glossary_entries;

import uim.platform.translation;
mixin(ShowModule!());

@safe:

interface GlossaryEntryRepository : ITenantRepository!(GlossaryEntry, GlossaryEntryId) {}
