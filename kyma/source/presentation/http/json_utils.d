module presentation.http.json_utils;

import vibe.data.json;
import vibe.http.server;

/// Extract a string field from a Json object.
string jsonStr(Json j, string key)
{
    if (!j.isObject)
        return "";
    auto v = key in j;
    if (v is null)
        return "";
    if ((*v).isString)
        return (*v).get!string;
    return "";
}

/// Extract a boolean field from a Json object.
bool jsonBool(Json j, string key, bool default_ = false)
{
    if (!j.isObject)
        return default_;
    auto v = key in j;
    if (v is null)
        return default_;
    if ((*v).type == Json.Type.bool_)
        return (*v).get!bool;
    return default_;
}

/// Extract a double field from a Json object.
double jsonDouble(Json j, string key, double default_ = 0)
{
    if (!j.isObject)
        return default_;
    auto v = key in j;
    if (v is null)
        return default_;
    if ((*v).type == Json.Type.float_)
        return (*v).get!double;
    if ((*v).type == Json.Type.int_)
        return cast(double)(*v).get!long;
    return default_;
}

/// Extract an integer field from a Json object.
long jsonLong(Json j, string key, long default_ = 0)
{
    if (!j.isObject)
        return default_;
    auto v = key in j;
    if (v is null)
        return default_;
    if ((*v).type == Json.Type.int_)
        return (*v).get!long;
    return default_;
}

/// Extract an int field from a Json object.
int jsonInt(Json j, string key, int default_ = 0)
{
    return cast(int) jsonLong(j, key, default_);
}

/// Extract a string array from a Json object.
string[] jsonStrArray(Json j, string key)
{
    if (!j.isObject)
        return [];
    auto v = key in j;
    if (v is null || (*v).type != Json.Type.array)
        return [];

    string[] result;
    foreach (item; *v)
    {
        if (item.isString)
            result ~= item.get!string;
    }
    return result;
}

/// Extract a string-to-string map from a Json object.
string[string] jsonStrMap(Json j, string key)
{
    if (!j.isObject)
        return (string[string]).init;
    auto v = key in j;
    if (v is null || (*v).type != Json.Type.object)
        return (string[string]).init;

    string[string] result;
    foreach (string k, val; *v)
    {
        if (val.isString)
            result[k] = val.get!string;
    }
    return result;
}

/// Write an error response as JSON.
void writeError(scope HTTPServerResponse res, int code, string msg)
{
    auto j = Json.emptyObject;
    j["error"] = Json(msg);
    j["code"] = Json(cast(long) code);
    res.writeJsonBody(j, cast(ushort) code);
}

/// Extract an ID from the end of a URI path.
string extractIdFromPath(string uri)
{
    import std.string : lastIndexOf;
    auto idx = uri.lastIndexOf('/');
    if (idx < 0 || idx + 1 >= uri.length)
        return "";
    auto rest = uri[idx + 1 .. $];
    auto qidx = rest.lastIndexOf('?');
    return qidx > 0 ? rest[0 .. qidx] : rest;
}

/// Serialize a string array to Json array.
Json serializeStrArray(string[] arr)
{
    auto result = Json.emptyArray;
    foreach (s; arr)
        result ~= Json(s);
    return result;
}

/// Serialize a string[string] map to Json object.
Json serializeStrMap(string[string] map)
{
    auto result = Json.emptyObject;
    foreach (k, v; map)
        result[k] = Json(v);
    return result;
}
