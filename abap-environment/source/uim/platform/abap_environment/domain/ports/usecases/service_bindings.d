/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.usecases.service_bindings;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for service binding CRUD.
interface ManageServiceBindingsUseCase { 

  CommandResult createServiceBinding(CreateServiceBindingRequest req);
  CommandResult updateServiceBinding(UpdateServiceBindingRequest req);
  ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId id);
  ServiceBinding[] listServiceBindings(TenantId tenantId, SystemInstanceId systemId);
  CommandResult deleteServiceBinding(TenantId tenantId, ServiceBindingId id);
  
}
