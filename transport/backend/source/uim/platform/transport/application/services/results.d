/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Uniform construction of use case results.
/// Codes: 400 invalid input, 404 not found, 409 conflict, 422 business rule violated.
module uim.platform.transport.application.services.results;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

UsecaseResult okResult(string id, string message, Json data = Json.emptyObject) {
  return UsecaseResult(true, id, message, 0, data);
}

UsecaseResult errorResult(size_t code, string message) {
  return UsecaseResult(false, "", message, code);
}

UsecaseResult notFoundResult(string what, string id) {
  return errorResult(404, what ~ " '" ~ id ~ "' not found");
}

/// The acting user, "system" if unknown.
string actor(string performedBy) {
  return performedBy.length > 0 ? performedBy : "system";
}

/// Same for a UserId.
string actor(UserId user) {
  return actor(user.value);
}
