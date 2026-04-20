/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.application;

// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// An external application connected to the Kyma environment.
struct Application {
  mixin TenantEntity!(ApplicationId);

  KymaEnvironmentId environmentId;
  string name;
  string description;
  AppConnectivityStatus status = AppConnectivityStatus.disconnected;
  AppRegistrationType registrationType = AppRegistrationType.apiAndEvents;

  // Connectivity
  string connectorUrl;
  string accessLabel;

  // Registered APIs
  AppApiEntry[] apis;

  // Registered event types
  AppEventEntry[] events;

  // Bound namespaces
  string[] boundNamespaces;

  // Labels
  string[string] labels;

  Json toJson() const {
    auto j = entityToJson
      .set("environmentId", environmentId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.toString())
      .set("registrationType", registrationType.toString())
      .set("connectorUrl", connectorUrl)
      .set("accessLabel", accessLabel)
      .set("apis", apis.map!(api => Json.init
        .set("name", api.name)
        .set("description", api.description)
        .set("targetUrl", api.targetUrl)
        .set("specUrl", api.specUrl)
        .set("authType", api.authType)).array)
      .set("events", events.map!(event => Json.init
        .set("name", event.name)
        .set("description", event.description)
        .set("version", event.version_)).array)
      .set("boundNamespaces", boundNamespaces.array)
      .set("labels", labels);

    return j;
  }
}

/// An API entry registered by an external application.
struct AppApiEntry {
  string name;
  string description;
  string targetUrl;
  string specUrl;
  string authType;
}

/// An event type registered by an external application.
struct AppEventEntry {
  string name;
  string description;
  string version_;
}
