/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.enumerations.resource;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Resource kinds that operations and labels refer to.
enum ResourceType : string {
  platform = "platform",
  serviceBroker = "serviceBroker",
  serviceOffering = "serviceOffering",
  servicePlan = "servicePlan",
  serviceInstance = "serviceInstance",
  serviceBinding = "serviceBinding"
}
