/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;





/// Extract an integer field from a Json object.


/// Extract an int field from a Json object.

/// Extract a ushort field from a Json object.
ushort jsonUshort(Json j, string key, ushort default_ = 0) {
  return cast(ushort) jsonLong(j, key, default_);
}








/// Convert a string array to a Json array.
Json toJsonArray(const(string[]) arr) {
  auto j = Json.emptyArray;
  foreach (s; arr)
    j ~= Json(s);
  return j;
}
