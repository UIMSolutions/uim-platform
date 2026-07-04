/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.ports.repositories.calls;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

interface RfcCallRepository {
    RfcCall   findById(TenantId tenantId, RfcCallId id);
    RfcCall[] findByTenant(TenantId tenantId);
    RfcCall[] findByDestination(TenantId tenantId, DestinationId destId);
    RfcCall[] findByTid(TenantId tenantId, TidValue tid);
    RfcCall[] findByStatus(TenantId tenantId, RfcStatus status);
    bool      save(RfcCall call);
    bool      update(RfcCall call);
    bool      remove(TenantId tenantId, RfcCallId id);
    size_t    countByTenant(TenantId tenantId);
}
