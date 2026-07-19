/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.json_utils;

import uim.platform.buildcode;
mixin(ShowModule!());

@safe:

Json jsonStr(string v)    { return Json(v); }
Json jsonBool(bool v)     { return Json(v); }
Json jsonInt(long v)      { return Json(v); }
Json jsonDouble(double v) { return Json(v); }

Json jsonStrArray(string[] items) {
  auto arr = Json.emptyArray;
  foreach (i; items) arr ~= Json(i);
  return arr;
}

string extractIdFromPath(HTTPServerRequest req) {
  auto path = req.requestPath.to!string;
  auto idx  = path.lastIndexOf('/');
  return idx >= 0 ? path[idx + 1 .. $] : path;
}

void writeError(HTTPServerResponse res, int status, string message) {
  auto j = Json.emptyObject;
  j["error"] = Json(message);
  res.writeJsonBody(j, status);
}
