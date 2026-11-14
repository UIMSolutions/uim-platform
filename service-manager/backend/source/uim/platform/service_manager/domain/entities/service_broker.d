/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.entities.service_broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// An Open Service Broker API compatible broker that advertises a catalog
/// of service offerings and plans.
struct ServiceBroker {
  mixin TenantEntity!ServiceBrokerId;

  string name;
  string description;
  string brokerUrl;
  string credentials; /// "user:password" for basic auth — secret
  ServiceBrokerStatus status = ServiceBrokerStatus.active;
  long lastCatalogFetch; /// std time of the last successful catalog sync (0 = never)
  string catalogError; /// message of the last failed catalog sync

  bool isActive() const {
    return status == ServiceBrokerStatus.active;
  }

  void validate() const {
    requireName(name, "Service broker");
    if (!isHttpUrl(brokerUrl))
      throw ServiceManagerException.invalid("Service broker brokerUrl must be an http(s) URL");
  }

  /// Record a successful catalog fetch.
  void catalogFetched(long at) {
    lastCatalogFetch = at;
    catalogError = "";
    if (status == ServiceBrokerStatus.registrationFailed)
      status = ServiceBrokerStatus.active;
  }

  /// Record a failed catalog fetch. A broker that never delivered a catalog
  /// is marked registrationFailed.
  void catalogFailed(string error) {
    catalogError = error;
    if (lastCatalogFetch == 0)
      status = ServiceBrokerStatus.registrationFailed;
  }
}

///
unittest {
  ServiceBroker b;
  b.name = "demo";
  b.brokerUrl = "https://broker.example.com";
  b.validate();
  b.catalogFailed("timeout");
  assert(b.status == ServiceBrokerStatus.registrationFailed);
  b.catalogFetched(42);
  assert(b.isActive && b.catalogError.length == 0 && b.lastCatalogFetch == 42);
}
