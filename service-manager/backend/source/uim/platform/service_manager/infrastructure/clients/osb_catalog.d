/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Open Service Broker API client: GET <brokerUrl>/v2/catalog.
module uim.platform.service_manager.infrastructure.clients.osb_catalog;

import core.time : seconds;
import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class OsbCatalogClient : IBrokerCatalogGateway {
  string apiVersion;
  uint timeoutSeconds;

  this(string apiVersion = "2.17", uint timeoutSeconds = 10) {
    this.apiVersion = apiVersion;
    this.timeoutSeconds = timeoutSeconds;
  }

  BrokerCatalog fetchCatalog(const ServiceBroker broker) @trusted {
    import std.base64 : Base64;
    import vibe.http.client : requestHTTP, HTTPClientSettings, HTTPClientRequest, HTTPClientResponse;
    import vibe.http.common : HTTPMethod;

    auto url = broker.brokerUrl.stripRight("/") ~ "/v2/catalog";
    auto settings = new HTTPClientSettings;
    settings.connectTimeout = timeoutSeconds.seconds;
    settings.readTimeout = timeoutSeconds.seconds;

    int status;
    string body;
    try {
      requestHTTP(url, (scope HTTPClientRequest req) {
        req.method = HTTPMethod.GET;
        req.headers["X-Broker-API-Version"] = apiVersion;
        req.headers["Accept"] = "application/json";
        if (broker.credentials.length > 0)
          req.headers["Authorization"] = "Basic " ~ cast(string) Base64.encode(cast(const(ubyte)[]) broker.credentials);
      }, (scope HTTPClientResponse res) {
        status = res.statusCode;
        body = res.bodyReader.readAllUTF8();
      }, settings);
    } catch (Exception e)
      throw ServiceManagerException.gateway(url ~ ": " ~ e.msg);

    if (status != 200)
      throw ServiceManagerException.gateway(format("%s answered HTTP %d", url, status));
    Json parsed;
    try
      parsed = parseJsonString(body);
    catch (Exception e)
      throw ServiceManagerException.gateway(url ~ " returned invalid JSON: " ~ e.msg);
    return parseOsbCatalog(parsed);
  }
}

/// Map an OSB catalog document to domain value objects.
BrokerCatalog parseOsbCatalog(Json doc) @trusted {
  if (!doc.isObject || "services" !in doc || doc["services"].type != Json.Type.array)
    throw ServiceManagerException.gateway("Catalog has no 'services' array");

  string str(Json o, string k) {
    return k in o && o[k].type == Json.Type.string ? o[k].get!string : "";
  }

  bool flag(Json o, string k, bool fallback) {
    return k in o && o[k].type == Json.Type.bool_ ? o[k].get!bool : fallback;
  }

  string jsonText(Json o, string k) {
    return k in o && (o[k].isObject || o[k].type == Json.Type.array) ? o[k].toString : "";
  }

  BrokerCatalog catalog;
  foreach (s; doc["services"]) {
    CatalogServiceDef svc;
    svc.id = str(s, "id");
    svc.name = str(s, "name");
    svc.description = str(s, "description");
    svc.bindable = flag(s, "bindable", true);
    svc.instancesRetrievable = flag(s, "instances_retrievable", false);
    svc.bindingsRetrievable = flag(s, "bindings_retrievable", false);
    svc.planUpdateable = flag(s, "plan_updateable", false);
    svc.metadata = jsonText(s, "metadata");
    if ("tags" in s && s["tags"].type == Json.Type.array)
      foreach (t; s["tags"])
        if (t.type == Json.Type.string)
          svc.tags ~= t.get!string;
    if ("plans" in s && s["plans"].type == Json.Type.array)
      foreach (p; s["plans"]) {
        CatalogPlanDef plan;
        plan.id = str(p, "id");
        plan.name = str(p, "name");
        plan.description = str(p, "description");
        plan.free = flag(p, "free", true);
        plan.bindable = flag(p, "bindable", svc.bindable);
        plan.planUpdateable = flag(p, "plan_updateable", svc.planUpdateable);
        plan.schemas = jsonText(p, "schemas");
        plan.metadata = jsonText(p, "metadata");
        if ("maximum_polling_duration" in p) {
        } // not modelled
        svc.plans ~= plan;
      }
    catalog.services ~= svc;
  }
  return catalog;
}

///
unittest {
  auto doc = parseJsonString(`{"services":[{"id":"s1","name":"redis","description":"Cache","bindable":true,
    "plan_updateable":true,"tags":["redis","data"],"metadata":{"displayName":"Redis"},
    "plans":[{"id":"p1","name":"small","free":true},{"id":"p2","name":"large","free":false,"bindable":false}]}]}`);
  auto c = parseOsbCatalog(doc);
  assert(c.services.length == 1 && c.services[0].plans.length == 2);
  assert(c.services[0].planUpdateable && c.services[0].tags == ["redis", "data"]);
  assert(!c.services[0].plans[1].free && !c.services[0].plans[1].bindable);
  assert(c.services[0].metadata.canFind("Redis"));
  assert(failsWith(ServiceManagerErrorKind.gateway, () { parseOsbCatalog(parseJsonString(`{}`)); }));
}
