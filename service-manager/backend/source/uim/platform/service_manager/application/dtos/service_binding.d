/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.service_binding;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Bindings are immutable once created (as in the OSB API).
struct CreateServiceBindingRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string instanceId;
  string name;
  string parameters;
  string bindResource;
  string context;
  string credentials; /// optional: generated if empty
}
