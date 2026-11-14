/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.enumerations.broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Registration state of a service broker.
enum ServiceBrokerStatus : string {
  active = "active",
  inactive = "inactive",
  registrationFailed = "registrationFailed"
}
