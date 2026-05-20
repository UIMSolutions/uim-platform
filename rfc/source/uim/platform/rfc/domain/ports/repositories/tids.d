/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.ports.repositories.tids;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

interface TidRepository {
    Tid    findById(string tenantId, TidValue value);
    Tid[]  findByTenant(string tenantId);
    Tid[]  findByDestination(string tenantId, DestinationId destId);
    Tid[]  findByStatus(string tenantId, LuwStatus status);
    bool   save(Tid tid);
    bool   update(Tid tid);
    bool   remove(string tenantId, TidValue value);
    size_t countByTenant(string tenantId);
}
