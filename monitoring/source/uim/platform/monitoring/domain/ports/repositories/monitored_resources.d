/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.repositories.monitored_resources;

// import uim.platform.monitoring.domain.entities.monitored_resource;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Port: outgoing - monitored resource persistence.
interface MonitoredResourceRepository : ITenantRepository!(MonitoredResource, MonitoredResourceId) {

  bool existsByName(TenantId tenantId, string name);
  MonitoredResource findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByType(TenantId tenantId, ResourceType type);
  MonitoredResource[] findByType(TenantId tenantId, ResourceType type);
  void removeByType(TenantId tenantId, ResourceType type);

}
