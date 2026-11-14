/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.application;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// An external system (e.g. SAP S/4HANA) connected through the Application
/// Connector, exposing APIs and events to bound namespaces.
struct KymaApplication {
  mixin TenantEntity!ApplicationId;

  KymaEnvironmentId environmentId;
  string name;
  string description;
  AppConnectivityStatus status = AppConnectivityStatus.disconnected;
  AppRegistrationType registrationType = AppRegistrationType.apiAndEvents;

  /// Connector URL the external system pairs with (derived).
  string connectorUrl;
  /// Label used to grant access in bound namespaces (derived).
  string accessLabel;

  AppApiEntry[] apis;
  AppEventEntry[] events;
  /// Names of the namespaces this application is bound to.
  string[] boundNamespaces;
  KeyValue[] labels;
}
