/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.infrastructure.persistence.memory.print_clients;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

class MemoryPrintClientRepository
    : TenantRepository!(PrintClient, PrintClientId), PrintClientRepository {

    PrintClient[] findByStatus(TenantId tenantId, PrintClientStatus status) {
        return findByTenant(tenantId).filter!(c => c.status == status).array;
    }

    PrintClient findByToken(TenantId tenantId, string authToken) {
        auto matches = findByTenant(tenantId).filter!(c => c.authToken == authToken).array;
        return matches.length > 0 ? matches[0] : PrintClient.init;
    }
}
