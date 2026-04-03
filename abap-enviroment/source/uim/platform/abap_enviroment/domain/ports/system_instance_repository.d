/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.system_instance_repository;

import uim.platform.abap_enviroment.domain.entities.system_instance;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - system instance persistence.
interface SystemInstanceRepository
{
  SystemInstance* findById(SystemInstanceId id);
  SystemInstance[] findByTenant(TenantId tenantId);
  SystemInstance* findByName(TenantId tenantId, string name);
  SystemInstance[] findByStatus(TenantId tenantId, SystemStatus status);
  void save(SystemInstance instance);
  void update(SystemInstance instance);
  void remove(SystemInstanceId id);
}
