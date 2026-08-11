/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.usecases.service_bindings;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
interface IManageServiceBindingsUseCase { 

  ServiceBindingResponse createServiceBinding(CreateServiceBindingRequest r);
  CommandResult updateServiceBinding(UpdateServiceBindingRequest r);
  ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId serviceBindingId);
  ServiceBinding[] listServiceBindings(TenantId tenantId);
  CommandResult deleteServiceBinding(TenantId tenantId, ServiceBindingId serviceBindingId);
  size_t countServiceBindings(TenantId tenantId);

}
