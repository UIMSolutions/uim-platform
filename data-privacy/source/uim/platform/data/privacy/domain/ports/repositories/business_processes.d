/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.business_processes;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.business_process;

/// Port for persisting and querying business processes.
interface BusinessProcessRepository : ITenantRepository!(BusinessProcess, BusinessProcessId) {
  
  size_t countByController(TenantId tenantId, DataControllerId controllerId);
  BusinessProcess[] findByController(TenantId tenantId, DataControllerId controllerId);
  void removeByController(TenantId tenantId, DataControllerId controllerId);

}
