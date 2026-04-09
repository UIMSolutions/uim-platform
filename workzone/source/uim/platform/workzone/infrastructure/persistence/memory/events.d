/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.events;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.event;
import uim.platform.workzone.domain.ports.repositories.events;

// import std.algorithm : filter;
// import std.array : array;

class MemoryEventRepository : EventRepository {
  private Event[EventId] store;

  Event[] findByWorkspace(WorkspaceId workspacetenantId, id tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.workspaceId == workspaceId).array;
  }

  Event* findById(EventId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Event[] findByOrganizer(UserId organizertenantId, id tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.organizerId == organizerId).array;
  }

  Event[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(Event event) {
    store[event.id] = event;
  }

  void update(Event event) {
    store[event.id] = event;
  }

  void remove(EventId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
