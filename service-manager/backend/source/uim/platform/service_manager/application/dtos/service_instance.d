/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.service_instance;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ProvisionServiceInstanceRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string name;
  string planId;
  string platformId; /// optional
  string context;
  string parameters;
  bool shared_;
}

struct UpdateServiceInstanceRequest {
  TenantId tenantId;
  UserId actor;
  ServiceInstanceId id;

  Patch!string name;
  Patch!string planId;
  Patch!string parameters;
  Patch!string context;
  Patch!bool shared_;
  Patch!bool usable;
}
