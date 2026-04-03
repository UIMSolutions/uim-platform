/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.domain.entities.service_binding;

import uim.platform.abap_enviroment.domain.types;

/// Exposed service endpoint from a binding.
struct ExposedEndpoint
{
  string path;
  string serviceName;
  string serviceVersion;
  bool requiresAuth = true;
}

/// Service binding that exposes CDS/RAP services via OData/REST/SOAP.
struct ServiceBinding
{
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
}
