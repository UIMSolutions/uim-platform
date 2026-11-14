/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Structured (JSON line) logging of service events.
module uim.platform.service_manager.infrastructure.logging.events;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

enum string logComponent = "uim-service-manager";

void logServiceEvent(string level, string message, Json fields = Json(null)) {
  logStructured(level, logComponent, message, fields);
}
