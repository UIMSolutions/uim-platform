/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.repositories.system_instance_repository;

import uim.platform.abap_enviroment.domain.entities.system_instance;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - system instance persistence.
interface SystemInstanceRepository {

  bool existsId(SystemInstanceId id);
  SystemInstance findById(SystemInstanceId id);
  
  bool existsName(TenantId tenantId, string name);
  SystemInstance findByName(TenantId tenantId, string name);

  SystemInstance[] findByTenant(TenantId tenantId);
  SystemInstance[] findByStatus(TenantId tenantId, SystemStatus status);
  void save(SystemInstance instance);
  void update(SystemInstance instance);
  void remove(SystemInstanceId id);
}
