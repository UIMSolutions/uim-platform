/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.events;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.event;

interface EventRepository {
  Event[] findByWorkspace(WorkspaceId workspacetenantId, id tenantId);
  Event* findById(EventId tenantId, id tenantId);
  Event[] findByOrganizer(UserId organizertenantId, id tenantId);
  Event[] findByTenant(TenantId tenantId);
  void save(Event event);
  void update(Event event);
  void remove(EventId tenantId, id tenantId);
}
