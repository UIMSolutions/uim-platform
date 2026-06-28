/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.infrastructure.persistence.memory.glossary_entries;

import uim.platform.translation;
import std.algorithm : filter;
import std.array : array;

// mixin(ShowModule!());

@safe:

class MemoryGlossaryEntryRepository : TenantRepository!(GlossaryEntry, GlossaryEntryId),
GlossaryEntryRepository {

    size_t countByLanguagePair(TenantId tenantId, string sourceLang, string targetLang) {
        return findByLanguagePair(tenantId, sourceLang, targetLang).length;
    }

    GlossaryEntry[] findByLanguagePair(TenantId tenantId, string sourceLang, string targetLang) {
        return find(tenantId)
            .filter!(e => e.sourceLanguage == sourceLang && e.targetLanguage == targetLang)
            .array;
    }

    void removeByLanguagePair(TenantId tenantId, string sourceLang, string targetLang) {
        findByLanguagePair(tenantId, sourceLang, targetLang).each!((e) => remove(e));
    }

    size_t countByDomain(TenantId tenantId, string domainName) {
        return findByDomain(tenantId, domainName).length;
    }

    GlossaryEntry[] findByDomain(TenantId tenantId, string domainName) {
        return find(tenantId)
            .filter!(e => e.domainName == domainName)
            .array;
    }

    void removeByDomain(TenantId tenantId, string domainName) {
        findByDomain(tenantId, domainName).each!((e) => remove(e));
    }
}
