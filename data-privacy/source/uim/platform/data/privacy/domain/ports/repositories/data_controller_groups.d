/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.data_controller_groups;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.data_controller_group;

/// Port for persisting and querying data controller groups.
interface DataControllerGroupRepository {
  bool existsTenant(TenantId tenantId);
  DataControllerGroup[] findByTenant(TenantId tenantId);
 
  bool existsId(DataControllerGroupId id, TenantId tenantId);
  DataControllerGroup findById(DataControllerGroupId id, TenantId tenantId);

  void save(DataControllerGroup group);
  void update(DataControllerGroup group);
  void remove(DataControllerGroupId id, TenantId tenantId);
}
