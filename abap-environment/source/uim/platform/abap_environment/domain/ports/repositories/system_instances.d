/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.system_instances;

// import uim.platform.abap_environment.domain.entities.system_instance;
// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Port: outgoing - system instance persistence.
interface SystemInstanceRepository : ITenantRepository!(SystemInstance, SystemInstanceId) {
  
  bool existsByName(TenantId tenantId, string name);
  SystemInstance findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByStatus(TenantId tenantId, SystemStatus status);
  SystemInstance[] findByStatus(TenantId tenantId, SystemStatus status);
  void removeByStatus(TenantId tenantId, SystemStatus status);

}
