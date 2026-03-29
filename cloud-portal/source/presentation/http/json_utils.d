module presentation.http.json_utils;

import vibe.data.json;
import std.traits;

/// Serialize a struct to JSON.
Json toJsonValue(T)(T val)
{
    auto j = Json.emptyObject;
    static foreach (i, field; T.tupleof)
    {{
        enum name = __traits(identifier, T.tupleof[i]);
        alias FT = typeof(field);
        static if (is(FT == string))
            j[name] = Json(val.tupleof[i]);
        else static if (is(FT == bool))
            j[name] = Json(val.tupleof[i]);
        else static if (is(FT == long) || is(FT == int) || is(FT == uint) || is(FT == ulong))
            j[name] = Json(cast(long) val.tupleof[i]);
        else static if (is(FT == string[]))
        {
            auto arr = Json.emptyArray;
            foreach (s; val.tupleof[i])
                arr ~= Json(s);
            j[name] = arr;
        }
        else static if (is(FT == enum))
        {
            import std.conv : to;
            j[name] = Json(val.tupleof[i].to!string);
        }
        else static if (is(FT == string[string]))
        {
            auto obj = Json.emptyObject;
            foreach (k, v; val.tupleof[i])
                obj[k] = Json(v);
            j[name] = obj;
        }
        else static if (isArray!FT && !is(FT == string))
        {
            auto arr = Json.emptyArray;
            foreach (item; val.tupleof[i])
                arr ~= toJsonValue(item);
            j[name] = arr;
        }
    }}
    return j;
}

/// Serialize an array of structs.
Json toJsonArray(T)(T[] items)
{
    auto arr = Json.emptyArray;
    foreach (item; items)
        arr ~= toJsonValue(item);
    return arr;
}

/// Read a string field from JSON, or return default.
string jsonStr(Json j, string key)
{
    if (j.type == Json.Type.object)
    {
        auto val = key in j;
        if (val !is null && (*val).type == Json.Type.string)
            return (*val).get!string;
    }
    return "";
}

/// Read a boolean field from JSON.
bool jsonBool(Json j, string key, bool default_ = false)
{
    if (j.type == Json.Type.object)
    {
        auto val = key in j;
        if (val !is null)
        {
            if ((*val).type == Json.Type.bool_)
                return (*val).get!bool;
        }
    }
    return default_;
}

/// Read an integer field from JSON.
long jsonLong(Json j, string key, long default_ = 0)
{
    if (j.type == Json.Type.object)
    {
        auto val = key in j;
        if (val !is null && (*val).type == Json.Type.int_)
            return (*val).get!long;
    }
    return default_;
}

/// Read a uint field from JSON.
uint jsonUint(Json j, string key, uint default_ = 0)
{
    return cast(uint) jsonLong(j, key, default_);
}

/// Read an int field from JSON.
int jsonInt(Json j, string key, int default_ = 0)
{
    return cast(int) jsonLong(j, key, default_);
}

/// Read a string array from JSON.
string[] jsonStrArray(Json j, string key)
{
    string[] result;
    if (j.type == Json.Type.object)
    {
        auto val = key in j;
        if (val !is null && (*val).type == Json.Type.array)
        {
            foreach (item; *val)
            {
                if (item.type == Json.Type.string)
                    result ~= item.get!string;
            }
        }
    }
    return result;
}

/// Extract the last segment of a request URI path as the resource ID.
string extractIdFromPath(string uri)
{
    import std.string : lastIndexOf;

    // Strip query string
    auto qIdx = uri.lastIndexOf('?');
    auto path = qIdx >= 0 ? uri[0 .. qIdx] : uri;

    // Strip trailing slash
    if (path.length > 0 && path[$ - 1] == '/')
        path = path[0 .. $ - 1];

    auto slashIdx = path.lastIndexOf('/');
    if (slashIdx >= 0 && slashIdx + 1 < path.length)
        return path[slashIdx + 1 .. $];
    return path;
}

/// Parse an enum from a JSON string field.
T jsonEnum(T)(Json j, string key, T default_ = T.init)
{
    auto str = jsonStr(j, key);
    if (str.length == 0)
        return default_;
    import std.conv : to;
    try
        return str.to!T;
    catch (Exception)
        return default_;
}

/// Write a standard JSON error response.
void writeApiError(scope HTTPServerResponse res, int status, string detail)
{
    auto response = Json.emptyObject;
    response["error"] = Json(detail);
    response["status"] = Json(cast(long) status);
    res.writeJsonBody(response, status);
}
