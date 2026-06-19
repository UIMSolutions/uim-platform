/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.presentation.http.json_utils;

import uim.platform.feature_flags;
import vibe.http.server : HTTPServerResponse, HTTPStatus;
import vibe.data.json   : Json;

// mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Safe JSON field readers
// ---------------------------------------------------------------------------

string getString(Json j, string key, string def = "") {
    if (j.type != Json.Type.object) return def;
    auto v = j[key];
    if (v.isString) return v.get!string;
    return def;
}

bool getBoolean(Json j, string key, bool def = false) {
    if (j.type != Json.Type.object) return def;
    auto v = j[key];
    if (v.isBoolean_) return v.get!bool;
    return def;
}

long getLong(Json j, string key, long def = 0) {
    if (j.type != Json.Type.object) return def;
    auto v = j[key];
    if (v.isInteger) return v.get!long;
    return def;
}

uint getUint(Json j, string key, uint def = 0) {
    return cast(uint) data.getLong(key, cast(long) def);
}

string[] getStringArray(Json j, string key) {
    if (j.type != Json.Type.object) return [];
    auto v = j[key];
    if (v.type != Json.Type.array) return [];
    string[] result;
    foreach (item; v)
        if (item.isString) result ~= item.get!string;
    return result;
}

string[string] getStringMap(Json j, string key) {
    if (j.type != Json.Type.object) return null;
    auto v = j[key];
    if (v.type != Json.Type.object) return null;
    string[string] result;
    foreach (string k, val; v)
        if (val.isString) result[k] = val.get!string;
    return result;
}

// ---------------------------------------------------------------------------
// Path extraction
// ---------------------------------------------------------------------------

/// Extract the last path segment after the final '/'.
string extractIdFromPath(string path) {
    import std.string : lastIndexOf;
    auto idx = path.lastIndexOf('/');
    if (idx < 0 || idx + 1 >= path.length) return "";
    return path[idx + 1 .. $];
}

// ---------------------------------------------------------------------------
// Standard response helpers
// ---------------------------------------------------------------------------

void writeError(HTTPServerResponse res, int status, string message) @safe {
    auto j = Json.emptyObject;
    j["error"]   = message;
    j["status"]  = status;
    res.writeJsonBody(j, status);
}

// ---------------------------------------------------------------------------
// Domain entity -> JSON serialisers
// ---------------------------------------------------------------------------

Json toJson(FeatureFlag f) {
    auto j = Json.emptyObject;
    j["id"]             = f.id.value;
    j["tenantId"]       = f.tenantId;
    j["name"]           = f.name;
    j["description"]    = f.description;
    j["type"]           = cast(string) f.type_;
    j["state"]          = cast(string) f.state_;
    j["instanceId"]     = f.instanceId.value;
    j["defaultVariant"] = f.defaultVariant;
    j["createdAt"]      = f.createdAt;
    j["updatedAt"]      = f.updatedAt;
    j["createdBy"]      = f.createdBy;
    j["updatedBy"]      = f.updatedBy;

    auto varArr = Json.emptyArray;
    foreach (v; f.variants) varArr ~= toJson(v);
    j["variants"] = varArr;

    auto ruleArr = Json.emptyArray;
    foreach (r; f.rules) ruleArr ~= toJson(r);
    j["rules"] = ruleArr;

    auto labels = Json.emptyObject;
    foreach (k, v; f.labels) labels[k] = v;
    j["labels"] = labels;

    return j;
}

Json toJson(FlagVariant v) {
    auto j = Json.emptyObject;
    j["id"]          = v.id.value;
    j["key"]         = v.key;
    j["name"]        = v.name;
    j["description"] = v.description;
    j["value"]       = v.value;
    j["weight"]      = cast(long) v.weight;
    return j;
}

Json toJson(TargetingRule r) {
    auto j = Json.emptyObject;
    j["id"]                  = r.id.value;
    j["name"]                = r.name;
    j["description"]         = r.description;
    j["type"]                = cast(string) r.type_;
    j["variantKey"]          = r.variantKey;
    j["priority"]            = cast(long) r.priority;
    j["rolloutPercentage"]   = cast(long) r.rolloutPercentage;

    auto ids = Json.emptyArray;
    foreach (id; r.targetIds) ids ~= id;
    j["targetIds"] = ids;

    auto attrs = Json.emptyObject;
    foreach (k, v; r.attributeConstraints) attrs[k] = v;
    j["attributeConstraints"] = attrs;

    return j;
}

Json toJson(ServiceInstance inst) {
    auto j = Json.emptyObject;
    j["id"]          = inst.id.value;
    j["tenantId"]    = inst.tenantId;
    j["name"]        = inst.name;
    j["description"] = inst.description;
    j["bindingGuid"] = inst.bindingGuid;
    j["createdAt"]   = inst.createdAt;
    j["updatedAt"]   = inst.updatedAt;
    j["createdBy"]   = inst.createdBy;
    j["updatedBy"]   = inst.updatedBy;

    auto labels = Json.emptyObject;
    foreach (k, v; inst.labels) labels[k] = v;
    j["labels"] = labels;

    return j;
}

Json toJson(EvaluationResult r) {
    auto j = Json.emptyObject;
    j["flagName"]     = r.flagName;
    j["variantKey"]   = r.variantKey;
    j["variantValue"] = r.variantValue;
    j["type"]         = cast(string) r.type_;
    j["enabled"]      = r.enabled;
    j["reason"]       = r.reason;
    return j;
}

Json toJson(AuditEntry e) {
    auto j = Json.emptyObject;
    j["id"]          = e.id.value;
    j["tenantId"]    = e.tenantId;
    j["action"]      = cast(string) e.action_;
    j["entityType"]  = e.entityType;
    j["entityId"]    = e.entityId;
    j["entityName"]  = e.entityName;
    j["performedBy"] = e.performedBy;
    j["performedAt"] = e.performedAt;
    return j;
}
