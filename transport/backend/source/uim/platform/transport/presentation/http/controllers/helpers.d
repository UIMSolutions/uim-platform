/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Shared helpers of the REST controllers.
module uim.platform.transport.presentation.http.controllers.helpers;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

enum string restBase = "/api/v1/transport";

/// Map a use case result to a REST response (UsecaseResult.code → HTTP status).
Json usecaseResponse(UsecaseResult r, string status, int okCode = 200) {
  if (!r.isSuccess)
    return errorResponse(r.message.length ? r.message : "Request failed", r.code > 0 ? cast(int) r.code : 400);
  auto data = r.data.type == Json.Type.object ? r.data.clone : Json.emptyObject;
  data["id"] = r.id;
  return successResponse(r.message, status, okCode, data);
}

/// PATCH semantics: the body value if present, otherwise the current value.
string pick(Json body, string key, string current) {
  if (body.type == Json.Type.object && key in body && body[key].type == Json.Type.string)
    return body[key].get!string;
  return current;
}

bool pickBool(Json body, string key, bool current) {
  if (body.type == Json.Type.object && key in body && body[key].type == Json.Type.bool_)
    return body[key].get!bool;
  return current;
}

int pickInt(Json body, string key, int current) {
  return body.type == Json.Type.object && key in body ? fieldInt(body, key, current) : current;
}

/// Wrap a list as { count, resources }.
Json listPayload(T)(const T[] items) {
  auto list = Json.emptyArray;
  foreach (i; items)
    list ~= i.toJson;
  return Json.emptyObject.set("count", items.length).set("resources", list);
}
