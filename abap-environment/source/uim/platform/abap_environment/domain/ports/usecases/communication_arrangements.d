/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.usecases.communication_arrangements;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for communication arrangement CRUD.
interface IManageCommunicationArrangementsUseCase { 

  CommandResult createArrangement(CreateCommunicationArrangementRequest req);
  CommandResult updateArrangement(UpdateCommunicationArrangementRequest req);
  CommunicationArrangement getArrangement(TenantId tenantId, CommunicationArrangementId id);
  CommunicationArrangement[] listArrangements(TenantId tenantId, SystemInstanceId systemId);
  CommandResult deleteArrangement(TenantId tenantId, CommunicationArrangementId id);

}
