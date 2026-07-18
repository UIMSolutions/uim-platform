/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.repositories.responsibility_contexts;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class MemoryResponsibilityContextRepository
    : TenantRepository!(ResponsibilityContext, ResponsibilityContextId),
      ResponsibilityContextRepository {

    ResponsibilityContext[] findByStatus(TenantId tenantId, ContextStatus status) {
        return findByTenant(tenantId).filter!(c => c.status == status).array;
    }

    ResponsibilityContext findByObjectType(TenantId tenantId, string objectType) {
        auto items = findByTenant(tenantId).filter!(c => c.objectType == objectType).array;
        return items.length > 0 ? items[0] : ResponsibilityContext.init;
    }
}
