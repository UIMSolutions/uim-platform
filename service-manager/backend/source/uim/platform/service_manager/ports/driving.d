/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (REST, OData,
/// CLI, GUI, workers) is allowed to call.
module uim.platform.service_manager.ports.driving;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct ServiceManagerPorts {
  IManagePlatforms platforms;
  IManageServiceBrokers brokers;
  IManageServiceOfferings offerings;
  IManageServicePlans plans;
  IManageServiceInstances instances;
  IManageServiceBindings bindings;
  IManageOperations operations;
  IManageLabels labels;
  ISyncBrokerCatalog catalogSync;
  IServiceManagerStatistics statistics;
}
