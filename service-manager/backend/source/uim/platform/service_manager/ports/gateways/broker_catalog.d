/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port to Open Service Broker API endpoints.
module uim.platform.service_manager.ports.gateways.broker_catalog;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IBrokerCatalogGateway {
  /// GET <brokerUrl>/v2/catalog. Throws ServiceManagerException.gateway on failure.
  BrokerCatalog fetchCatalog(const ServiceBroker broker);
}
