/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.memory.audit_entry_repo;

import uim.platform.feature_flags;
import std.algorithm : filter;
import std.array     : array;

mixin(ShowModule!());

@safe:

class MemoryAuditEntryRepository : AuditEntryRepository {
    private AuditEntry[] entries;

    void append(AuditEntry entry) {
        entries ~= entry;
    }

    AuditEntry[] findByTenant(TenantId tenantId) {
        return entries.filter!(e => e.tenantId == tenantId).array;
    }

    AuditEntry[] findByEntity(TenantId tenantId, string entityId) {
        return entries.filter!(e => e.tenantId == tenantId && e.entityId == entityId).array;
    }

    AuditEntry[] findByTenantPaged(TenantId tenantId, size_t offset, size_t limit) {
        auto all = findByTenant(tenantId);
        if (offset >= all.length) return [];
        auto end = offset + limit;
        if (end > all.length) end = all.length;
        return all[offset .. end];
    }
}
