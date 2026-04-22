/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.communication_arrangements;

import uim.platform.abap_environment.domain.entities.communication_arrangement;
import uim.platform.abap_environment.domain.types;

/// Port: outgoing - communication arrangement persistence.
interface CommunicationArrangementRepository : ITenantRepository!(CommunicationArrangement, CommunicationArrangementId) {

  size_t countBySystem(SystemInstanceId systemId);
  CommunicationArrangement[] findBySystem(SystemInstanceId systemId);
  void removeBySystem(SystemInstanceId systemId);

  size_t countByDirection(SystemInstanceId systemId, CommunicationDirection dir);
  CommunicationArrangement[] findByDirection(SystemInstanceId systemId, CommunicationDirection dir);
  void removeByDirection(SystemInstanceId systemId, CommunicationDirection dir);

}
