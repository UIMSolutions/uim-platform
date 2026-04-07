/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.business_processes;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.business_process;

/// Port for persisting and querying business processes.
interface BusinessProcessRepository {
  bool existsByTenant(TenantId tenantId);
  BusinessProcess[] findByTenant(TenantId tenantId);
 
  bool existsId(BusinessProcessId id, TenantId tenantId);
  BusinessProcess findById(BusinessProcessId id, TenantId tenantId);
  
  BusinessProcess[] findByController(TenantId tenantId, DataControllerId controllerId);

  void save(BusinessProcess process);
  void update(BusinessProcess process);
  void remove(BusinessProcessId id, TenantId tenantId);
}
