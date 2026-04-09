/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.repositories.destinations;

import uim.platform.connectivity.domain.entities.destination;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - destination persistence.
interface DestinationRepository : ITenantRepository!(Destination, DestinationId) {
  Destination findByName(TenantId tenantId, string name);
  Destination[] findByProxyType(TenantId tenantId, ProxyType proxyType);
}
