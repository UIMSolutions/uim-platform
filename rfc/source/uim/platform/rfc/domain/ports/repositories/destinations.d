/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.ports.repositories.destinations;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

interface DestinationRepository {
    Destination   findById(TenantId tenantId, DestinationId id);
    Destination[] findByTenant(TenantId tenantId);
    bool          save(Destination dest);
    bool          update(Destination dest);
    bool          remove(TenantId tenantId, DestinationId id);
    size_t        countByTenant(TenantId tenantId);
}
