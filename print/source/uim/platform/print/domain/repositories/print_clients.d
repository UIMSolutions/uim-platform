/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.repositories.print_clients;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

interface PrintClientRepository : ITenantRepository!(PrintClient, PrintClientId) {
    PrintClient[] findByStatus(TenantId tenantId, PrintClientStatus status);
    PrintClient findByToken(TenantId tenantId, string authToken);
}
