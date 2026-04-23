/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.repositories.service_binding;

// import uim.platform.abap_environment.domain.entities.service_binding;
// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Port: outgoing - service binding persistence.
interface ServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {

  size_t countBySystem(SystemInstanceId systemId);
  ServiceBinding[] findBySystem(SystemInstanceId systemId);
  void removeBySystem(SystemInstanceId systemId);

  size_t countByType(SystemInstanceId systemId, BindingType bindingType);
  ServiceBinding[] findByType(SystemInstanceId systemId, BindingType bindingType);
  void removeByType(SystemInstanceId systemId, BindingType bindingType);

}
