/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.file.service_instances;

import uim.platform.postgres;
import std.file     : exists, mkdirRecurse, readText, write;
import std.path     : buildPath;
import std.algorithm : filter, any;
import std.array    : array;
import std.conv     : to;
import std.string   : lastIndexOf;

mixin(ShowModule!());

@safe:

class FileServiceInstanceRepository
    : TenantRepository!(ServiceInstance, ServiceInstanceId)
    , ServiceInstanceRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "service_instances.json");
    }

    private void persistTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        mkdirRecurse(path[0 .. path.lastIndexOf('/')]);
        Json arr = Json.emptyArray;
        foreach (i; findByTenant(tenantId)) arr ~= i.toJson();
        write(path, arr.toString());
    }

    private void loadTenant(TenantId tenantId) @trusted {
        auto path = filePath(tenantId);
        if (!exists(path)) return;
        auto arr = parseJson(readText(path));
        if (!arr.isArray) return;
        foreach (j; arr.byValue()) {
            ServiceInstance e;
            e.id            = ServiceInstanceId(data.getString("id", ""));
            e.tenantId      = tenantId;
            e.name          = data.getString("name", "");
            e.description   = data.getString("description", "");
            e.planId        = ServicePlanId(data.getString("planId", ""));
            e.status        = data.getString("status", "provisioning").to!InstanceStatus;
            e.hyperscaler   = data.getString("hyperscaler", "aws").to!Hyperscaler;
            e.region        = data.getString("region", "");
            e.engineVersion = data.getString("engineVersion", "16").to!PostgresVersion;
            e.memoryGb      = data.getLong("memoryGb", 4);
            e.storageGb     = data.getLong("storageGb", 20);
            e.host          = data.getString("host", "");
            e.port          = cast(ushort) data.getLong("port", 5432);
            e.dbName        = data.getString("dbName", "");
            e.sslEnabled    = data.getBoolean("sslEnabled", true);
            e.multiAz       = data.getBoolean("multiAz", false);
            e.provisionedAt = data.getLong("provisionedAt", 0);
            e.updatedAt     = data.getLong("updatedAt", 0);
            e.createdAt     = data.getLong("createdAt", 0);
            e.createdBy     = UserId(data.getString("createdBy", ""));
            e.updatedBy     = UserId(data.getString("updatedBy", ""));
            super.save(e);
        }
    }

    override void createTenant(TenantId tenantId) { super.createTenant(tenantId); loadTenant(tenantId); }
    override void save(ServiceInstance item)       { super.save(item); persistTenant(item.tenantId); }
    override void update(ServiceInstance item)     { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId tenantId, ServiceInstanceId id) {
        super.removeById(tenantId, id); persistTenant(tenantId);
    }

    override ServiceInstance[] findByStatus(TenantId t, InstanceStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override ServiceInstance[] findByPlan(TenantId t, ServicePlanId planId) {
        return findByTenant(t).filter!(e => e.planId == planId).array;
    }
    override ServiceInstance[] findByHyperscaler(TenantId t, Hyperscaler hs) {
        return findByTenant(t).filter!(e => e.hyperscaler == hs).array;
    }
    override bool nameExists(TenantId t, string name) {
        return findByTenant(t).any!(e => e.name == name);
    }
}
