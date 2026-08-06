/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.service_bindings;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface IManageServiceBindingsUseCase {

  CommandResult create(TenantId tenantId, CreateServiceBindingRequest req);
  ServiceBinding getById(TenantId tenantId, string id);
  ServiceBinding[] list(TenantId tenantId);
  ServiceBinding[] listByProject(TenantId tenantId, string projectId);
  CommandResult remove(TenantId tenantId, string id);

}
