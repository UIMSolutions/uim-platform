/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.services.log_parser;
// import uim.platform.logging.domain.entities.log_entry;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct ParseResult {
  bool valid;
  string[] errors;
  LogEntry entry;

  Json toJson() const {
    return Json.emptyObject
      .set("valid", valid)
      .set("errors", errors.toJson())
      .set("entry", entry.toJson());
  }
}

struct LogParser {
  static ParseResult validate(const ref LogEntry entry) {
    string[] errors;

    if (entry.tenantId.isEmpty)
      errors ~= "Tenant ID is required";
    if (entry.message.length == 0)
      errors ~= "Log message is required";
    if (entry.timestamp <= 0)
      errors ~= "Timestamp must be positive";

    ParseResult result;
    result.valid = errors.length == 0;
    result.errors = errors;
    return result;
  }
}
