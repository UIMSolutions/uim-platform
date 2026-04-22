/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.ports.repositories.destinations;

// import uim.platform.destination.domain.entities.destination;
// import uim.platform.destination.domain.types;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// Port: outgoing — destination configuration persistence.
interface DestinationRepository : ITenantRepository!(Destination, DestinationId) {

  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name);
  Destination findByName(TenantId tenantId, SubaccountId subaccountId, string name);
  void removeByName(TenantId tenantId, SubaccountId subaccountId, string name);

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  Destination[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId);

  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  Destination[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);

  size_t countByLevel(TenantId tenantId, SubaccountId subaccountId, DestinationLevel level);
  Destination[] findByLevel(TenantId tenantId, SubaccountId subaccountId, DestinationLevel level);
  void removeByLevel(TenantId tenantId, SubaccountId subaccountId, DestinationLevel level);
  
}
