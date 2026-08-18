/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.presentation.http.json_utils;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

Json jsonBool(bool v)     { return Json(v); }
Json jsonInt(long v)      { return Json(v); }
Json jsonDouble(double v) { return Json(v); }

Json jsonStrArray(string[] items) {
  return items.map!toJson.array.toJson;
}
