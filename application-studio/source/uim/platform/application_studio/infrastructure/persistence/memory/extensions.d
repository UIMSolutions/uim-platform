/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.extensions;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class MemoryExtensionRepository : TenantRepository!(Extension, ExtensionId), ExtensionRepository {

    size_t countByScope(TenantId tenantId, ExtensionScope scope_) {
        return findByScope(tenantId, scope_).length;
    }

    Extension[] findByScope(TenantId tenantId, ExtensionScope scope_) {
        return find(tenantId).filter!(e => e.scope_ == scope_).array;
    }

    void removeByScope(TenantId tenantId, ExtensionScope scope_) {
        findByScope(tenantId, scope_).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, ExtensionStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Extension[] findByStatus(TenantId tenantId, ExtensionStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, ExtensionStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
