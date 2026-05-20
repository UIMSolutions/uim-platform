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
    RfcCall   findById(string tenantId, RfcCallId id);
    RfcCall[] findByTenant(string tenantId);
    RfcCall[] findByDestination(string tenantId, DestinationId destId);
    RfcCall[] findByTid(string tenantId, TidValue tid);
    RfcCall[] findByStatus(string tenantId, RfcStatus status);
    bool      save(RfcCall call);
    bool      update(RfcCall call);
    bool      remove(string tenantId, RfcCallId id);
    size_t    countByTenant(string tenantId);
}
