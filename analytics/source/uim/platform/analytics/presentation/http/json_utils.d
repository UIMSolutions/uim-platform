module uim.platform.analytics.presentation.http.json_utils;

import std.conv : to;
import std.string : indexOf;
import vibe.data.json : Json;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.analytics;
mixin(ShowModule!());

@safe:
string tenantFromQuery(scope HTTPServerRequest req) {
  auto tenant = req.query.get("tenantId", "");
  if (tenant.length == 0) return "default";
  return tenant;
}

string extractAssetId(scope HTTPServerRequest req) {
  auto path = req.requestPath.to!string;
  auto marker = "/api/v1/analytics/assets/";
  auto idx = path.indexOf(marker);
  if (idx < 0) return "";

  auto remainder = path[idx + marker.length .. $];
  auto slash = remainder.indexOf("/");
  if (slash >= 0) return remainder[0 .. slash];
  return remainder;
}

void writeError(scope HTTPServerResponse res, int status, string message) {
  auto payload = Json.emptyObject;
  payload["error"] = Json(message);
  res.writeJsonBody(payload, status);
}

string[] readStringArray(Json obj, string key) {
  string[] values;
  if (!obj.isArray(key)) return values;
  
  foreach (item; obj.getArray(key)) {
    if (item.isString)
      values ~= item.get!string;
  }
  return values;
}
