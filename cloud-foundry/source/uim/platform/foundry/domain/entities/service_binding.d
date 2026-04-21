/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.entities.service_binding;

// import uim.platform.foundry.domain.types;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// A service binding — connects an application to a service instance,
/// injecting credentials into the application's VCAP_SERVICES environment.
struct ServiceBinding {
  mixin TenantEntity!(ServiceBindingId);

  AppId appId;
  ServiceInstanceId serviceInstanceId;
  string name;
  BindingStatus status = BindingStatus.creating;
  string credentials; // JSON string of binding credentials
  string bindingOptions; // JSON string of binding parameters
  
  Json toJson() const {
    return Json.entityToJson
        .set("appId", appId)
        .set("serviceInstanceId", serviceInstanceId)
        .set("name", name)
        .set("status", status.to!string)
        .set("credentials", credentials)
        .set("bindingOptions", bindingOptions);
  }
}
