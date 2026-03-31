module presentation.http.json_utils;

import vibe.data.json;
import vibe.http.server;

/// Extract a string field from a Json object.
string jsonStr(Json j, string key)
{
    if (j.type != Json.Type.object)
        return "";
    auto v = key in j;
    if (v is null)
        return "";
    if ((*v).type == Json.Type.string)
        return (*v).get!string;
    return "";
}

/// Extract a boolean field from a Json object.
bool jsonBool(Json j, string key, bool default_ = false)
{
    if (j.type != Json.Type.object)
        return default_;
    auto v = key in j;
    if (v is null)
        return default_;
    if ((*v).type == Json.Type.bool_)
        return (*v).get!bool;
    return default_;
}

/// Extract a long field from a Json object.
long jsonLong(Json j, string key, long default_ = 0)
{
    if (j.type != Json.Type.object)
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
    if (j.type != Json.Type.object)
        return [];
    auto v = key in j;
    if (v is null || (*v).type != Json.Type.array)
        return [];

    string[] result;
    foreach (item; *v)
    {
        if (item.type == Json.Type.string)
            result ~= item.get!string;
    }
    return result;
}

/// Extract a string-to-string map from a Json object.
string[string] jsonStrMap(Json j, string key)
{
    if (j.type != Json.Type.object)
        return (string[string]).init;
    auto v = key in j;
    if (v is null || (*v).type != Json.Type.object)
        return (string[string]).init;

    string[string] result;
    foreach (string k, val; *v)
    {
        if (val.type == Json.Type.string)
            result[k] = val.get!string;
    }
    return result;
}

/// Write an error response.
void writeError(scope HTTPServerResponse res, int status, string message)
{
    auto j = Json.emptyObject;
    j["error"] = Json(message);
    j["status"] = Json(cast(long) status);
    res.writeJsonBody(j, status);
}

/// Extract the last path segment as ID from a URI.
string extractId(string uri)
{
    import std.string : lastIndexOf;
    auto qIdx = uri.lastIndexOf('?');
    auto path = qIdx >= 0 ? uri[0 .. qIdx] : uri;
    auto idx = path.lastIndexOf('/');
    if (idx < 0)
        return path;
    return path[idx + 1 .. $];
}

/// Serialize a string-to-string map to Json.
Json serializeStrMap(string[string] map)
{
    auto j = Json.emptyObject;
    foreach (k, v; map)
        j[k] = Json(v);
    return j;
}

/// Serialize a string array to Json.
Json serializeStrArray(string[] arr)
{
    auto j = Json.emptyArray;
    foreach (s; arr)
        j ~= Json(s);
    return j;
}
