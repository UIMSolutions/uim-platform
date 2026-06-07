/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.ports.repositories.audit_entries;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

/// Port for append-only audit log persistence.
interface AuditEntryRepository {
    void      append(AuditEntry entry);
    AuditEntry[] findByTenant(TenantId tenantId);
    AuditEntry[] findByEntity(TenantId tenantId, string entityId);
    AuditEntry[] findByTenantPaged(TenantId tenantId, size_t offset, size_t limit);
}
