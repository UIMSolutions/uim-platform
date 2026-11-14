/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// URLs derived from system and binding data.
module uim.platform.abap_environment.domain.services.service_urls;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// The relative service URL of a binding ("" for binding types without an HTTP endpoint).
string bindingServiceUrl(BindingType type, string serviceDefinition, string binding, string serviceVersion) {
  auto srvd = serviceDefinition.toLower;
  auto name = binding.toLower;
  final switch (type) {
  case BindingType.odataV4Ui, BindingType.odataV4WebApi:
    return "/sap/opu/odata4/sap/" ~ name ~ "/srvd_a2x/sap/" ~ srvd ~ "/" ~ serviceVersion ~ "/";
  case BindingType.odataV2Ui, BindingType.odataV2WebApi:
    return "/sap/opu/odata/sap/" ~ binding.toUpper ~ "/";
  case BindingType.soapHttp:
    return "/sap/bc/srt/scs_ext/sap/" ~ name ~ "/";
  case BindingType.restHttp:
    return "/sap/bc/http/sap/" ~ name ~ "/";
  case BindingType.sqlWebApi, BindingType.inboundRfc:
    return "";
  }
}

/// The $metadata URL of an OData binding ("" otherwise).
string bindingMetadataUrl(BindingType type, string serviceUrl) {
  return type.isOData && serviceUrl.length > 0 ? serviceUrl ~ "$metadata" : "";
}

///
unittest {
  auto url = bindingServiceUrl(BindingType.odataV4Ui, "ZUI_TRAVEL", "ZUI_TRAVEL_O4", "0001");
  assert(url == "/sap/opu/odata4/sap/zui_travel_o4/srvd_a2x/sap/zui_travel/0001/");
  assert(bindingMetadataUrl(BindingType.odataV4Ui, url) == url ~ "$metadata");
  assert(bindingServiceUrl(BindingType.odataV2Ui, "ZUI", "ZUI_O2", "0001") == "/sap/opu/odata/sap/ZUI_O2/");
  assert(bindingMetadataUrl(BindingType.restHttp, "/x/") == "");
  assert(bindingServiceUrl(BindingType.inboundRfc, "X", "Y", "0001") == "");
}
