/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.manage_service_brokers;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IManageServiceBrokers {
  ServiceBroker[] listBrokers(TenantId tenantId);
  ServiceBroker getBroker(TenantId tenantId, ServiceBrokerId id);
  ServiceBroker registerBroker(RegisterServiceBrokerRequest request);
  ServiceBroker updateBroker(UpdateServiceBrokerRequest request);
  /// Removes the broker with its offerings and plans; refused while instances exist.
  void deregisterBroker(TenantId tenantId, ServiceBrokerId id);
}
