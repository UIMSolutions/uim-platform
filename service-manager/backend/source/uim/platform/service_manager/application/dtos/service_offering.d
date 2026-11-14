/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.service_offering;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct CreateServiceOfferingRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string brokerId;
  string name;
  string description;
  string catalogId;
  string catalogName;
  string category;
  Patch!bool bindable;
  Patch!bool instancesRetrievable;
  Patch!bool bindingsRetrievable;
  Patch!bool planUpdateable;
  string metadata;
  string[] tags;
}

struct UpdateServiceOfferingRequest {
  TenantId tenantId;
  UserId actor;
  ServiceOfferingId id;

  Patch!string name;
  Patch!string description;
  Patch!string catalogName;
  Patch!string category;
  Patch!string status;
  Patch!bool bindable;
  Patch!bool instancesRetrievable;
  Patch!bool bindingsRetrievable;
  Patch!bool planUpdateable;
  Patch!string metadata;
  Patch!(string[]) tags;
}
