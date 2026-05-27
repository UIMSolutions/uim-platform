/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.file.service_instances;

import uim.platform.redis;
import std.file   : exists, mkdirRecurse, readText, write;
import std.path   : buildPath;
import std.algorithm : filter, any;
import std.array  : array;
import std.conv   : to;

mixin(ShowModule!());

@safe:

/// File-backed repository for ServiceInstance.
/// Persists each tenant's data as a JSON file under basePath/{tenantId}/service_instances.json.
class FileServiceInstanceRepository
    : TenantRepository!(ServiceInstance, ServiceInstanceId)
    , ServiceInstanceRepository
{
    private string _basePath;

    this(string basePath) {
        _basePath = basePath;
    }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "service_instances.json");
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        mkdirRecurse(path[0 .. path.lastIndexOf('/')]);
        auto items = findByTenant(tenantId);
        Json arr = Json.emptyArray;
        foreach (i; items) arr ~= i.toJson();
        write(path, arr.toString());
    }

    private void loadTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        if (!exists(path)) return;
        auto text = readText(path);
        auto arr  = parseJson(text);
        if (!arr.isArray) return;
        foreach (j; arr.byValue()) {
            ServiceInstance inst;
            inst.id          = ServiceInstanceId(j.getString("id", ""));
            inst.tenantId    = tenantId;
            inst.name        = j.getString("name", "");
            inst.description = j.getString("description", "");
            inst.planId      = ServicePlanId(j.getString("planId", ""));
            inst.status      = j.getString("status", "active").to!InstanceStatus;
            inst.hyperscaler = j.getString("hyperscaler", "aws").to!Hyperscaler;
            inst.region      = j.getString("region", "");
            inst.redisVersion = j.getString("redisVersion", "7.x").to!RedisVersion;
            inst.memoryMb    = j.getLong("memoryMb", 256);
            inst.maxConnections = j.getLong("maxConnections", 10000);
            inst.host        = j.getString("host", "");
            inst.port        = cast(ushort) j.getLong("port", 6379);
            inst.tlsEnabled  = j.getBoolean("tlsEnabled", true);
            inst.haEnabled   = j.getBoolean("haEnabled", false);
            inst.persistenceMode = j.getString("persistenceMode", "none").to!PersistenceMode;
            inst.provisionedAt = j.getLong("provisionedAt", 0);
            inst.updatedAt   = j.getLong("updatedAt", 0);
            inst.createdAt   = j.getLong("createdAt", 0);
            super.save(inst);
        }
    }

    override void createTenant(TenantId tenantId) {
        super.createTenant(tenantId);
        loadTenant(tenantId);
    }

    override void save(ServiceInstance item) {
        super.save(item);
        persistTenant(item.tenantId);
    }

    override void update(ServiceInstance item) {
        super.update(item);
        persistTenant(item.tenantId);
    }

    override void removeById(TenantId tenantId, ServiceInstanceId id) {
        super.removeById(tenantId, id);
        persistTenant(tenantId);
    }

    override ServiceInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    override ServiceInstance[] findByPlan(TenantId tenantId, ServicePlanId planId) {
        return findByTenant(tenantId).filter!(e => e.planId == planId).array;
    }

    override ServiceInstance[] findByHyperscaler(TenantId tenantId, Hyperscaler hs) {
        return findByTenant(tenantId).filter!(e => e.hyperscaler == hs).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(e => e.name == name);
    }
}
