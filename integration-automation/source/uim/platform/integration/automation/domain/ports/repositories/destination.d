/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.destination;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.destination;

/// Port for persisting and querying destinations.
interface DestinationRepository : ITenantRepository!(Destination, DestinationId) {

  bool existsByName(TenantId tenantId, string name);
  Destination findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countBySystem(TenantId tenantId, SystemConnectionId systemId);
  Destination[] findBySystem(TenantId tenantId, SystemConnectionId systemId);
  void removeBySystem(TenantId tenantId, SystemConnectionId systemId);

  size_t countEnabled(TenantId tenantId);
  Destination[] findEnabled(TenantId tenantId);
  void removeEnabled(TenantId tenantId);

}
