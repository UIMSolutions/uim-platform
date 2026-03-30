module uim.platform.analytics.infrastructure.web.json_utils;

import vibe.data.json;
import std.traits;

/// Serialize a struct to a Json value.
Json toJsonValue(T)(T obj) if (is(T == struct)) {
    return serializeToJson(obj);
}

/// Serialize an array of structs to a Json array.
Json toJsonArray(T)(T[] arr) if (is(T == struct)) {
    auto jArr = Json.emptyArray;
    foreach (item; arr)
        jArr ~= serializeToJson(item);
    return jArr;
}

/// Helper: standard JSON error response body.
Json errorJson(string message, int code = 400) {
    auto j = Json.emptyObject;
    j["error"] = message;
    j["code"] = code;
    return j;
}

/// Helper: envelope a result with metadata.
Json envelopeJson(string key, Json data) {
    auto j = Json.emptyObject;
    j[key] = data;
    return j;
}
