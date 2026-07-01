module uim.platform.abap_environment.application.dtos.service_binding;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:

struct CreateServiceBindingRequest {
  TenantId tenantId;
  ServiceBindingId bindingId;
  SystemInstanceId instanceId;
  ServiceDefinitionId definitionId;
  
  string name;
  string description;
  string bindingType; // "odataV2", "odataV4", ...
  ExposedEndpoint[] endpoints;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("bindingId", bindingId.value)
      .set("instanceId", instanceId.value)
      .set("definitionId", definitionId.value)
      .set("name", name)
      .set("description", description)
      .set("bindingType", bindingType)
      .set("endpoints", endpoints.map!(e => e.toJson()).array.toJson);
  }
}

struct UpdateServiceBindingRequest {
  TenantId tenantId;
  ServiceBindingId serviceBindingId;
  
  string description;
  string status; // "active", "inactive", "deprecated_"
  ExposedEndpoint[] endpoints;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("serviceBindingId", serviceBindingId.value)
      .set("description", description)
      .set("status", status)
      .set("endpoints", endpoints.map!(e => e.toJson()).array.toJson);
  }
}