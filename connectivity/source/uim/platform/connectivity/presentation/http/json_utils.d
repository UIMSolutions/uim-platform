module uim.platform.connectivity.presentation.http.json_utils;

// import vibe.data.json;
// import vibe.http.server;

/// Extract a string field from a Json object.
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

/// Extract a boolean field from a Json object.
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

/// Extract an integer field from a Json object.
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

/// Extract an int field from a Json object.
int jsonInt(Json j, string key, int default_ = 0) {
    return cast(int)jsonLong(j, key, default_);
}

/// Extract a ushort field from a Json object.
ushort jsonUshort(Json j, string key, ushort default_ = 0) {
    return cast(ushort)jsonLong(j, key, default_);
}

/// Extract a string array from a Json object.
string[] jsonStrArray(Json j, string key) {
    if (!j.isObject)
        return [];
    auto v = key in j;
    if (v is null || (*v).type != Json.Type.array)
        return [];

    string[] result;
    foreach (item; *v) {
        if (item.isString)
            result ~= item.get!string;
    }
    return result;
}

/// Convert a string array to a Json array.
Json toJsonArray(const(string[]) arr) {
    auto jarr = Json.emptyArray;
    foreach (s; arr)
        jarr ~= Json(s);
    return jarr;
}

/// Extract the last path segment from a URI (for wildcard routes).
string extractIdFromPath(string uri) {
    // import std.string : indexOf;

    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;

    if (path.length > 0 && path[$ - 1] == '/')
        path = path[0 .. $ - 1];

    auto spos = lastIndexOf(path, '/');
    if (spos >= 0 && spos + 1 < path.length)
        return path[spos + 1 .. $];
    return path;
}

private long lastIndexOf(string s, char c) {
    for (long i = cast(long)s.length - 1; i >= 0; --i)
        if (s[cast(size_t)i] == c)
            return i;
    return -1;
}

/// Write a JSON error response.
void writeError(scope HTTPServerResponse res, int status, string message) {
    auto j = Json.emptyObject;
    j["error"] = Json(message);
    j["status"] = Json(status);
    res.writeJsonBody(j, status);
}
