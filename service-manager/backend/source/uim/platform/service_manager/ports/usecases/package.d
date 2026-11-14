/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports, one per aggregate. All getters throw
/// ServiceManagerException.notFound for unknown ids.
module uim.platform.service_manager.ports.usecases;

public {
  import uim.platform.service_manager.ports.usecases.manage_platforms;
  import uim.platform.service_manager.ports.usecases.manage_service_brokers;
  import uim.platform.service_manager.ports.usecases.manage_service_offerings;
  import uim.platform.service_manager.ports.usecases.manage_service_plans;
  import uim.platform.service_manager.ports.usecases.manage_service_instances;
  import uim.platform.service_manager.ports.usecases.manage_service_bindings;
  import uim.platform.service_manager.ports.usecases.manage_operations;
  import uim.platform.service_manager.ports.usecases.manage_labels;
  import uim.platform.service_manager.ports.usecases.sync_broker_catalog;
}
