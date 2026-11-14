/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.enumerations.client;

import uim.platform.events;

mixin(ShowModule!());

@safe:

enum MessageClientStatus : string {
  active = "active",
  inactive = "inactive",
  suspended = "suspended"
}

/// Wire protocol a client uses to talk to the broker.
enum MessageClientProtocol : string {
  amqp10 = "amqp10",
  mqtt311 = "mqtt311",
  mqtt500 = "mqtt500",
  httprest = "httprest"
}
