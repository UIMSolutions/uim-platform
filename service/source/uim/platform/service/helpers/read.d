/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.helpers.read;

import uim.platform.service;

mixin(ShowModule!());

@safe:

SysTime parseTime(string value) {
  try
  {
    return SysTime.fromISOExtString(value);
  }
  catch (Exception)
  {
    return SysTime.fromISOExtString("1970-01-01T00:00:00Z");
  }
}

SysTime readTime(Json item, string key) {
  return !(key in item) || !item[key].isString
    ? SysTime.fromISOExtString("1970-01-01T00:00:00Z") : parseTime(item[key].get!string);
}

string[] readStringArray(Json data, string key) {
  string[] values;
  if (!(key in data) || data[key].isNull)
    return values;

  requiredArrayType(data, key);

  foreach (item; data[key].toArray)
  {
    if (!item.isString)
      throw new UIMValidationException(key ~ " must contain strings");

    values ~= item.getString;
  }
  return values;
}
/// 
unittest {
  // import std.stdio : writeln;

  void testReadStringArray()
  {
    Json data = Json.parse(`{"names": ["Alice", "Bob", "Charlie"]}`);
    string[] names = readStringArray(data, "names");
    assert(names.length == 3);
    assert(names[0] == "Alice");
    assert(names[1] == "Bob");
    assert(names[2] == "Charlie");
  }

  void testReadTime()
  {
    Json data = Json.parse(`{"timestamp": "2024-01-01T12:00:00Z"}`);
    SysTime time = readTime(data, "timestamp");
    assert(time.toISOExtString == "2024-01-01T12:00:00Z");
  }
}

Json readObject(Json data, string key, Json fallback = Json.emptyObject) {
  if (!(key in data) || data[key].isNull)
  {
    return fallback;
  }

  requiredObjectType(data, key);
  return data[key];
}
