/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.service_binding;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// A RAP service binding exposing a CDS service definition (OData, SOAP, REST, SQL, RFC).
struct ServiceBinding {
  mixin TenantEntity!ServiceBindingId;

  SystemInstanceId systemInstanceId;
  string systemName;
  string name; /// e.g. "ZUI_TRAVEL_O4"
  string description;
  string serviceDefinition; /// e.g. "ZUI_TRAVEL"
  BindingType bindingType = BindingType.odataV4Ui;
  string serviceVersion = "0001";
  BindingStatus status = BindingStatus.unpublished;

  ExposedEndpoint[] endpoints;
  string serviceUrl; /// relative to the system's service URL
  string metadataUrl;
  long publishedAt;
}
