/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.manage_service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IManageServiceBindings {
  ServiceBinding[] listBindings(TenantId tenantId);
  ServiceBinding getBinding(TenantId tenantId, ServiceBindingId id);
  ServiceBinding createBinding(CreateServiceBindingRequest request);
  void deleteBinding(TenantId tenantId, ServiceBindingId id, UserId actor);
}
