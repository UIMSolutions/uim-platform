/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.service_binding;

import uim.platform.abap_environment.domain.types;

/// Exposed service endpoint from a binding.
struct ExposedEndpoint {
  string path;
  string serviceName;
  string serviceVersion;
  bool requiresAuth = true;
}

/// Service binding that exposes CDS/RAP services via OData/REST/SOAP.
struct ServiceBinding {
  ServiceBindingId id;
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  ServiceDefinitionId serviceDefinitionId;
  string name;
  string description;

  BindingType bindingType = BindingType.odataV4;
  BindingStatus status = BindingStatus.active;

  /// Exposed endpoints
  ExposedEndpoint[] endpoints;

  /// Runtime URL
  string serviceUrl;
  string metadataUrl;

  /// Metadata
  string createdBy;
  long createdAt;
  long updatedAt;
  
  Json toJson() const {
    auto j = Json.emptyObject
      .set("id", id)
      .set("tenantId", tenantId)
      .set("systemInstanceId", systemInstanceId)
      .set("serviceDefinitionId", serviceDefinitionId)
      .set("name", name)
      .set("description", description)
      .set("bindingType", bindingType.to!string)
      .set("status", status.to!string)
      .set("serviceUrl", serviceUrl)
      .set("metadataUrl", metadataUrl)
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);

    if (endpoints.length > 0) {
      auto eps = endpoints.map!(e => e.toJson).array.toJson;
      j = j.set("endpoints", eps);
    }

    return j;
  }
}
