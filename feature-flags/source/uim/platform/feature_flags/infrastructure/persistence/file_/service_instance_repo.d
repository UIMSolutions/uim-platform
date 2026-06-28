/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.file_.service_instance_repo;

import uim.platform.feature_flags;
import vibe.data.json : Json, parseJsonString;
import std.file       : exists, mkdirRecurse, write, readText, dirEntries, SpanMode, remove;
import std.path       : buildPath;
import std.algorithm  : filter;
import std.array      : array;

// mixin(ShowModule!());

@safe:

class FileServiceInstanceRepository : ServiceInstanceRepository {
    private string basePath;

    this(string basePath) {
        this.basePath = buildPath(basePath, "_instances");
    }

    void save(ServiceInstance inst) {
        ensureDir(inst.tenantId);
        write(instPath(inst.tenantId, inst.id.value), serialise(inst));
    }

    void update(ServiceInstance inst) { save(inst); }

    void remove(ServiceInstance inst) @trusted {
        auto p = instPath(inst.tenantId, inst.id.value);
        if (p.exists) std.file.remove(p);
    }

    ServiceInstance findById(TenantId tenantId, ServiceInstanceId id) @trusted {
        auto p = instPath(tenantId, id.value);
        if (!p.exists) return ServiceInstance.init;
        return deserialise(readText(p));
    }

    ServiceInstance findByName(TenantId tenantId, string name) {
        foreach (inst; find(tenantId))
            if (inst.name == name) return inst;
        return ServiceInstance.init;
    }

    ServiceInstance[] findByTenant(TenantId tenantId) @trusted {
        auto dir = buildPath(basePath, tenantId);
        if (!dir.exists) return [];
        ServiceInstance[] result;
        foreach (entry; dirEntries(dir, "*.json", SpanMode.shallow))
            result ~= deserialise(readText(entry.name));
        return result;
    }

    size_t countByTenant(TenantId tenantId) {
        return find(tenantId).length;
    }

    private:

    void ensureDir(TenantId tenantId) @trusted {
        auto dir = buildPath(basePath, tenantId);
        if (!dir.exists) mkdirRecurse(dir);
    }

    string instPath(TenantId tenantId, string id) const {
        return buildPath(basePath, tenantId, id ~ ".json");
    }

    string serialise(ServiceInstance inst) {
        return toJson(inst).toPrettyString();
    }

    ServiceInstance deserialise(string text) {
        auto j = parseJsonString(text);
        ServiceInstance inst;
        inst.id          = ServiceInstanceId(j["id"].get!string);
        inst.tenantId    = j["tenantId"].get!string;
        inst.name        = j["name"].get!string;
        inst.description = j["description"].get!string;
        inst.bindingGuid = j["bindingGuid"].get!string;
        inst.createdAt   = j["createdAt"].get!string;
        inst.updatedAt   = j["updatedAt"].get!string;
        inst.createdBy   = j["createdBy"].get!string;
        inst.updatedBy   = j["updatedBy"].get!string;
        foreach (string k, val; j["labels"]) inst.labels[k] = val.get!string;
        return inst;
    }
}
