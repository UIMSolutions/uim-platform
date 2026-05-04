/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.entities.destination_fragment;

// import uim.platform.destination.domain.types;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// A reusable destination fragment — partial configuration that can be merged into destinations.
struct DestinationFragment {
  mixin TenantEntity!FragmentId;
  
  SubaccountId subaccountId;
  string name;
  string description;
  DestinationLevel level = DestinationLevel.subaccount;

  // Fragment configuration properties (merged into destination at resolution time)
  string url;
  string authenticationType;
  string proxyType;
  string user;
  string password;
  string clientId;
  string clientSecret;
  string tokenServiceUrl;
  string locationId;
  CertificateId keystoreId;
  CertificateId truststoreId;
  string[string] properties;

  Json toJson() const {
    auto propsJson = Json.emptyObject;
    foreach (k, v; properties)
      propsJson[k] = Json(v);

    return entityToJson()
      .set("subaccountId", subaccountId.toJson())
      .set("name", name)
      .set("description", description)
      .set("level", level.to!string)
      .set("url", url)
      .set("authentication", authenticationType)
      .set("proxyType", proxyType)
      .set("locationId", locationId)
      .set("keystoreId", keystoreId.toJson())
      .set("truststoreId", truststoreId.toJson())
      .set("properties", propsJson);
  }
}
