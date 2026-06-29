/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.infrastructure.persistence.memory.applications;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

class MemoryApplicationRepository : TenantRepository!(Application, ApplicationId), ApplicationRepository {
    Application findByClient(TenantId tenantId, string clientId) {
        foreach (a; findByTenant(tenantId))
            if (a.clientId == clientId) return a;
        return Application.init;
    }

    Application[] findByStatus(TenantId tenantId, AppStatus status) {
        return findByTenant(tenantId).filter!(a => a.status == status).array;
    }

    Application[] findByProtocol(TenantId tenantId, AppProtocol protocol) {
        return findByTenant(tenantId).filter!(a => a.protocol == protocol).array;
    }
}
