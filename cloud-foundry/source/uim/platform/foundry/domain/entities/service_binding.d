/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.service_binding;

import uim.platform.foundry.domain.types;

/// A service binding — connects an application to a service instance,
/// injecting credentials into the application's VCAP_SERVICES environment.
struct ServiceBinding {
  ServiceBindingId id;
  AppId appId;
  ServiceInstanceId serviceInstanceId;
  TenantId tenantId;
  string name;
  BindingStatus status = BindingStatus.creating;
  string credentials; // JSON string of binding credentials
  string bindingOptions; // JSON string of binding parameters
  string createdBy;
  long createdAt;
}
