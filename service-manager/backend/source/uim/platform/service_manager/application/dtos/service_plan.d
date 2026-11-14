/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.service_plan;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct CreateServicePlanRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string offeringId;
  string name;
  string description;
  string catalogId;
  string catalogName;
  string pricing;
  Patch!bool bindable;
  Patch!bool planUpdateable;
  int maxInstances;
  string schemas;
  string metadata;
}

struct UpdateServicePlanRequest {
  TenantId tenantId;
  UserId actor;
  ServicePlanId id;

  Patch!string name;
  Patch!string description;
  Patch!string catalogName;
  Patch!string pricing;
  Patch!bool bindable;
  Patch!bool planUpdateable;
  Patch!int maxInstances;
  Patch!string schemas;
  Patch!string metadata;
}
