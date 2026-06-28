/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.file_.feature_flag_repo;

import uim.platform.feature_flags;
import vibe.data.json   : Json, parseJsonString, serializeToJsonString;
import std.file         : exists, mkdirRecurse, write, readText, dirEntries, SpanMode, remove;
import std.path         : buildPath;
import std.algorithm    : filter;
import std.array        : array;
import std.conv         : to;

// mixin(ShowModule!());

@safe:

/// File-based feature flag repository.
/// Each flag is persisted as a JSON file: {basePath}/{tenantId}/{flagId}.json
class FileFeatureFlagRepository : FeatureFlagRepository {
    private string basePath;

    this(string basePath) {
        this.basePath = basePath;
    }

    void save(FeatureFlag flag_) {
        ensureDir(flag_.tenantId);
        write(flagPath(flag_.tenantId, flag_.id.value), serialise(flag_));
    }

    void update(FeatureFlag flag_) {
        save(flag_);
    }

    void remove(FeatureFlag flag_) @trusted {
        auto p = flagPath(flag_.tenantId, flag_.id.value);
        if (p.exists) std.file.remove(p);
    }

    FeatureFlag findById(TenantId tenantId, FlagId id) @trusted {
        auto p = flagPath(tenantId, id.value);
        if (!p.exists) return FeatureFlag.init;
        return deserialise(readText(p));
    }

    FeatureFlag findByName(TenantId tenantId, ServiceInstanceId instanceId, string name) {
        foreach (f; find(tenantId))
            if (f.instanceId == instanceId && f.name == name) return f;
        return FeatureFlag.init;
    }

    FeatureFlag[] findByTenant(TenantId tenantId) @trusted {
        auto dir = buildPath(basePath, tenantId);
        if (!dir.exists) return [];
        FeatureFlag[] result;
        foreach (entry; dirEntries(dir, "*.json", SpanMode.shallow))
            result ~= deserialise(readText(entry.name));
        return result;
    }

    FeatureFlag[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return find(tenantId).filter!(f => f.instanceId == instanceId).array;
    }

    FeatureFlag[] findByState(TenantId tenantId, ServiceInstanceId instanceId, FlagState state_) {
        return findByInstance(tenantId, instanceId).filter!(f => f.state_ == state_).array;
    }

    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByInstance(tenantId, instanceId).length;
    }

    private:

    void ensureDir(TenantId tenantId) @trusted {
        auto dir = buildPath(basePath, tenantId);
        if (!dir.exists) mkdirRecurse(dir);
    }

    string flagPath(TenantId tenantId, string id) const {
        return buildPath(basePath, tenantId, id ~ ".json");
    }

    string serialise(FeatureFlag f) {
        return toJson(f).toPrettyString();
    }

    FeatureFlag deserialise(string text) {
        auto j = parseJsonString(text);
        FeatureFlag f;
        f.id          = FlagId(j["id"].get!string);
        f.tenantId    = j["tenantId"].get!string;
        f.name        = j["name"].get!string;
        f.description = j["description"].get!string;
        
        f.type_       = j["type"].get!string.to!FlagType;
        f.state_      = j["state"].get!string.to!FlagState;
        f.instanceId  = ServiceInstanceId(j["instanceId"].get!string);
        f.defaultVariant = j["defaultVariant"].get!string;
        f.createdAt   = j["createdAt"].get!string;
        f.updatedAt   = j["updatedAt"].get!string;
        f.createdBy   = j["createdBy"].get!string;
        f.updatedBy   = j["updatedBy"].get!string;

        foreach (v; j["variants"])
            f.variants ~= FlagVariant(
                VariantId(v["id"].get!string), v["key"].get!string,
                v["name"].get!string, v["description"].get!string,
                v["value"].get!string, cast(uint) v["weight"].get!long
            );

        foreach (r; j["rules"]) {
            TargetingRule tr;
            tr.id         = RuleId(r["id"].get!string);
            tr.name       = r["name"].get!string;
            tr.type_      = r["type"].get!string.to!RuleType;
            tr.variantKey = r["variantKey"].get!string;
            tr.priority   = cast(uint) r["priority"].get!long;
            tr.rolloutPercentage = cast(uint) r["rolloutPercentage"].get!long;
            foreach (id; r["targetIds"]) tr.targetIds ~= id.get!string;
            foreach (string k, val; r["attributeConstraints"])
                tr.attributeConstraints[k] = val.get!string;
            f.rules ~= tr;
        }

        foreach (string k, val; j["labels"])
            f.labels[k] = val.get!string;

        return f;
    }
}
