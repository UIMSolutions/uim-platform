/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Structured (JSON line) logging of service events. Secrets, tokens and
/// codes are never logged.
module uim.platform.oauth.infrastructure.logging.oauth;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

enum string logComponent = "uim-oauth";

void logServiceEvent(string level, string message, Json fields = Json(null)) {
  logStructured(level, logComponent, message, fields);
}
