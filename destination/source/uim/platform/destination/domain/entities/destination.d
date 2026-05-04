/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.entities.destination;

// import uim.platform.destination.domain.types;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// A destination configuration — defines how to connect to a remote system.
struct Destination {
  mixin TenantEntity!DestinationId;

  SubaccountId subaccountId;
  ServiceInstanceId serviceInstanceId;
  string name;
  string description;
  DestinationType destinationType = DestinationType.http;
  string url;
  AuthenticationType authenticationType = AuthenticationType.noAuthentication;
  ProxyType proxyType = ProxyType.internet;
  DestinationLevel level = DestinationLevel.subaccount;
  DestinationStatus status = DestinationStatus.active;

  // HTTP-specific
  string urlPath;
  string httpMethod;

  // Authentication details
  string user;
  string password;
  string clientId;
  string clientSecret;
  string tokenServiceUrl;
  string tokenServiceUser;
  string tokenServicePassword;
  string audience;
  string systemUser;
  string samlAudience;
  string nameIdFormat;
  string authnContextClassRef;

  // Certificate references
  CertificateId keystoreId;
  string keystorePassword;
  CertificateId truststoreId;

  // On-premise / Cloud Connector
  string locationId;
  string sccVirtualHost;
  ushort sccVirtualPort;

  // Custom properties
  string[string] properties;

  // Fragment references
  FragmentId[] fragmentIds;

  Json toJson() const {
    auto fragArr = d.fragmentIds.map!(fid => fid.toJson).array.toJson;

    auto propsJson = Json.emptyObject;
    foreach (k, v; properties)
      propsJson[k] = Json(v);

    return entityToJson()
      .set("subaccountId", subaccountId.toJson())
      .set("serviceInstanceId", serviceInstanceId.toJson())
      .set("name", name)
      .set("description", description)
      .set("type", destinationType.to!string)
      .set("url", url)
      .set("authentication", authenticationType.to!string)
      .set("proxyType", proxyType.to!string)
      .set("level", level.to!string)
      .set("status", status.to!string)
      .set("urlPath", urlPath)
      .set("httpMethod", httpMethod)
      .set("locationId", locationId)
      .set("keystoreId", keystoreId.toJson())
      .set("truststoreId", truststoreId.toJson())
      .set("fragmentIds", fragArr)
      .set("properties", propsJson);
  }
}
