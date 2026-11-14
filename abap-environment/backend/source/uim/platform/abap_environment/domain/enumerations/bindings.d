/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.enumerations.bindings;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Binding type of a RAP service binding.
enum BindingType {
  odataV4Ui,
  odataV4WebApi,
  odataV2Ui,
  odataV2WebApi,
  soapHttp,
  restHttp,
  sqlWebApi,
  inboundRfc,
}

/// True for OData binding types (they have a $metadata document).
bool isOData(BindingType t) pure nothrow {
  return t == BindingType.odataV4Ui || t == BindingType.odataV4WebApi
    || t == BindingType.odataV2Ui || t == BindingType.odataV2WebApi;
}

/// Publication status of a service binding.
enum BindingStatus {
  unpublished,
  published,
  deprecated_, /// "deprecated"
}
