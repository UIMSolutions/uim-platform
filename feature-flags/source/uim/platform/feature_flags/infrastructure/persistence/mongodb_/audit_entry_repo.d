/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.mongodb_.audit_entry_repo;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

class MongoDbAuditEntryRepository : AuditEntryRepository {
    private MemoryAuditEntryRepository fallback;
    private string connectionUri;
    private string dbName;

    this(string connectionUri, string dbName) {
        this.connectionUri = connectionUri;
        this.dbName        = dbName;
        this.fallback      = new MemoryAuditEntryRepository();
        // TODO: connect and wire mongo collection
    }

    void append(AuditEntry entry)                              { fallback.append(entry);               }
    AuditEntry[] findByTenant(TenantId tenantId)               { return fallback.findByTenant(tenantId); }
    AuditEntry[] findByEntity(TenantId tenantId, string entityId) { return fallback.findByEntity(tenantId, entityId); }
    AuditEntry[] findByTenantPaged(TenantId tenantId, size_t offset, size_t limit) {
        return fallback.findByTenantPaged(tenantId, offset, limit);
    }
}
