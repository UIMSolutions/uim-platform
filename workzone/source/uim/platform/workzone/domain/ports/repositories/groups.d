/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.groups;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.group;

interface GroupRepository {
  Group[] findByTenant(TenantId tenantId);
  Group* findById(GroupId id, TenantId tenantId);
  Group[] findByMember(UserId userId, TenantId tenantId);
  void save(Group group);
  void update(Group group);
  void remove(GroupId id, TenantId tenantId);
}
