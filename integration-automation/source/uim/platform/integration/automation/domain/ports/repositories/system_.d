/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.system_;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.system_connection;

/// Port for persisting and querying system connections.
interface SystemRepository {
  SystemConnection[] findByTenant(TenantId tenantId);
  SystemConnection* findById(SystemId tenantId, id tenantId);
  SystemConnection[] findByType(TenantId tenantId, SystemType systemType);
  SystemConnection[] findByStatus(TenantId tenantId, ConnectionStatus status);
  void save(SystemConnection system);
  void update(SystemConnection system);
  void remove(SystemId tenantId, id tenantId);
}
