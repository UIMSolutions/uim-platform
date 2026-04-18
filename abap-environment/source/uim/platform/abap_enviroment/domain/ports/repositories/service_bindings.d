/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.ports.repositories.service_binding;

import uim.platform.abap_enviroment.domain.entities.service_binding;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - service binding persistence.
interface ServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {
  // ServiceBinding* findById(ServiceBindingId id);
  ServiceBinding[] findBySystem(SystemInstanceId systemId);
  // ServiceBinding[] findByTenant(TenantId tenantId);
  ServiceBinding[] findByType(SystemInstanceId systemId, BindingType bindingType);
  // void save(ServiceBinding binding);
  // void update(ServiceBinding binding);
  // void remove(ServiceBindingId id);
}
