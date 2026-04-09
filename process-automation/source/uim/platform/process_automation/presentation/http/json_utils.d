/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.json_utils;

import uim.platform.process_automation;

string jsonStr(Json j, string key) {
    if (!j.isObject)
        return "";
    auto v = key in j;
    if (v is null)
        return "";
    if ((*v).isString)
        return (*v).get!string;
    return "";
}

bool jsonBool(Json j, string key, bool default_ = false) {
    if (!j.isObject)
        return default_;
    auto v = key in j;
    if (v is null)
        return default_;
    if ((*v).isBoolean)
        return (*v).get!bool;
    return default_;
}

int jsonInt(Json j, string key, int default_ = 0) {
    if (!j.isObject)
        return default_;
    auto v = key in j;
    if (v is null)
        return default_;
    if ((*v).isInteger)
        return cast(int)(*v).get!long;
    return default_;
}

long jsonLong(Json j, string key, long default_ = 0) {
    if (!j.isObject)
        return default_;
    auto v = key in j;
    if (v is null)
        return default_;
    if ((*v).isInteger)
        return (*v).get!long;
    return default_;
}

double jsonDouble(Json j, string key, double default_ = 0.0) {
    if (!j.isObject)
        return default_;
    auto v = key in j;
    if (v is null)
        return default_;
    if ((*v).isFloat)
        return (*v).get!double;
    if ((*v).isInteger)
        return cast(double)(*v).get!long;
    return default_;
}

string[] jsonStrArray(Json j, string key) {
    if (!j.isObject)
        return [];
    auto v = key in j;
    if (v is null)
        return [];
    if ((*v).type != Json.Type.array)
        return [];
    string[] result;
    foreach (item; *v) {
        if (item.isString)
            result ~= item.get!string;
    }
    return result;
}

string[][] jsonKeyValuePairs(Json j, string key) {
    if (!j.isObject)
        return [];
    auto v = key in j;
    if (v is null)
        return [];
    if ((*v).type != Json.Type.array)
        return [];
    string[][] result;
    foreach (item; *v) {
        if (item.isObject) {
            auto k = item.getString("key");
            auto val = item.getString("value");
            if (k.length > 0)
                result ~= [k, val];
        }
    }
    return result;
}

Json stringsToJsonArray(string[] arr) {
    auto jarr = Json.emptyArray;
    foreach (s; arr)
        jarr ~= Json(s);
    return jarr;
}

string extractIdFromPath(string path) {
    import std.string : lastIndexOf;

    if (path.length == 0)
        return "";
    auto idx = lastIndexOf(path, '/');
    if (idx < 0 || idx + 1 >= path.length)
        return "";
    return path[idx + 1 .. $];
}
