/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.infrastructure.persistence.memory
  .communication_arrangement_repo;

import uim.platform.abap_enviroment.domain.types;
import uim.platform.abap_enviroment.domain.entities.communication_arrangement;
import uim.platform.abap_enviroment.domain.ports.communication_arrangement_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryCommunicationArrangementRepository : CommunicationArrangementRepository
{
  private CommunicationArrangement[CommunicationArrangementId] store;

  CommunicationArrangement* findById(CommunicationArrangementId id)
  {
    if (auto p = id in store)
      return p;
    return null;
  }

  CommunicationArrangement[] findBySystem(SystemInstanceId systemId)
  {
    return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
  }

  CommunicationArrangement[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  CommunicationArrangement[] findByDirection(SystemInstanceId systemId, CommunicationDirection dir)
  {
    return store.byValue().filter!(e => e.systemInstanceId == systemId && e.direction == dir).array;
  }

  void save(CommunicationArrangement arrangement)
  {
    store[arrangement.id] = arrangement;
  }

  void update(CommunicationArrangement arrangement)
  {
    store[arrangement.id] = arrangement;
  }

  void remove(CommunicationArrangementId id)
  {
    store.remove(id);
  }
}
