/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.repositories.communication_arrangements;

import uim.platform.abap_enviroment.domain.entities.communication_arrangement;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - communication arrangement persistence.
interface CommunicationArrangementRepository {
  CommunicationArrangement* findById(CommunicationArrangementId id);
  CommunicationArrangement[] findBySystem(SystemInstanceId systemId);
  CommunicationArrangement[] findByTenant(TenantId tenantId);
  CommunicationArrangement[] findByDirection(SystemInstanceId systemId, CommunicationDirection dir);
  void save(CommunicationArrangement arrangement);
  void update(CommunicationArrangement arrangement);
  void remove(CommunicationArrangementId id);
}
