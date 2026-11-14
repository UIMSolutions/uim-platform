/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.service_broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct RegisterServiceBrokerRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string name;
  string description;
  string brokerUrl;
  string credentials; /// "user:password"
}

struct UpdateServiceBrokerRequest {
  TenantId tenantId;
  UserId actor;
  ServiceBrokerId id;

  Patch!string name;
  Patch!string description;
  Patch!string brokerUrl;
  Patch!string credentials;
  Patch!string status;
}
