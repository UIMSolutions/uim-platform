/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.repositories.data_controller_groups;

// import uim.platform.data_privacy.domain.entities.data_controller_group;
import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying data controller groups.
interface IDataControllerGroupRepository : ITenantRepository!(DataControllerGroup, DataControllerGroupId) {

  size_t countByName(TenantId tenantId, string name);
  DataControllerGroup[] findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);
  
}
