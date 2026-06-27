/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.infrastructure.persistence.memory.print_documents;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class MemoryPrintDocumentRepository
    : TentRepository!(PrintDocument, PrintDocumentId), PrintDocumentRepository {

    PrintDocument[] findByFormat(TenantId tenantId, DocumentFormat format) {
        return findByTenant(tenantId).filter!(d => d.format == format).array;
    }

    PrintDocument[] findExpired(TenantId tenantId, long nowTimestamp) {
        return findByTenant(tenantId)
            .filter!(d => d.expiresAt > 0 && d.expiresAt < nowTimestamp)
            .array;
    }

    void removeExpired(TenantId tenantId, long nowTimestamp) {
        findExpired(tenantId, nowTimestamp).each!(d => remove(d));
    }
}
