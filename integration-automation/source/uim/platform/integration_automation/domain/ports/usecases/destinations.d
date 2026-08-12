/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.domain.ports.usecases.destinations;

// import uim.platform.integration_automation.domain.ports.repositories.systems;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:
interface IManageDestinationsUseCase { 

  CommandResult createDestination(CreateDestinationRequest req);

  Destination getDestination(TenantId tenantId, DestinationId id);

  Destination[] listDestinations(TenantId tenantId);

  Destination[] listBySystem(TenantId tenantId, SystemConnectionId systemId);

  Destination[] listEnabled(TenantId tenantId);

  CommandResult updateDestination(UpdateDestinationRequest req);

  CommandResult deleteDestination(TenantId tenantId, DestinationId id);
  
}
