/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.files.common;

import std.conv : to;
import vibe.data.json : Json;

@safe:

string jstr(Json j, string key, string fallback = "") {
    try {
        auto v = j[key];
        if (v.type == Json.Type.object) {
            try return v["value"].get!string;
            catch (Exception) {}
        }
        return v.get!string;
    } catch (Exception) {
        return fallback;
    }
}

long jlong(Json j, string key, long fallback = 0) {
    try return j[key].get!long;
    catch (Exception) return fallback;
}

E jenum(E)(Json j, string key, E fallback) {
    auto value = jstr(j, key, "");
    if (value.length == 0)
        return fallback;

    try return value.to!E;
    catch (Exception) return fallback;
}
