/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.system_;

// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.system_connection;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying system connections.
interface SystemRepository : ITenantRepository!(SystemConnection, SystemConnectionId) {

  size_t countByType(TenantId tenantId, SystemType systemType);
  SystemConnection[] findByType(TenantId tenantId, SystemType systemType);
  void removeByType(TenantId tenantId, SystemType systemType);

  size_t countByStatus(TenantId tenantId, ConnectionStatus status);
  SystemConnection[] findByStatus(TenantId tenantId, ConnectionStatus status);
  void removeByStatus(TenantId tenantId, ConnectionStatus status);
}
