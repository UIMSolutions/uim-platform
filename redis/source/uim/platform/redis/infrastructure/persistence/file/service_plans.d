/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.file.service_plans;

import uim.platform.redis;
import std.file   : exists, mkdirRecurse, readText, write;
import std.path   : buildPath;
import std.algorithm : filter, any;
import std.array  : array;
import std.conv   : to;

mixin(ShowModule!());

@safe:

class FileServicePlanRepository
    : TenantRepository!(ServicePlan, ServicePlanId)
    , ServicePlanRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "service_plans.json");
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
            ServicePlan p;
            p.id          = ServicePlanId(data.getString("id", ""));
            p.tenantId    = tenantId;
            p.name        = data.getString("name", "");
            p.description = data.getString("description", "");
            p.tier        = data.getString("tier", "basic").to!PlanTier;
            p.memoryMb    = data.getLong("memoryMb", 256);
            p.maxConnections = data.getLong("maxConnections", 1000);
            p.haEnabled   = data.getBoolean("haEnabled", false);
            p.persistenceEnabled = data.getBoolean("persistenceEnabled", false);
            p.tlsEnabled  = data.getBoolean("tlsEnabled", true);
            p.pricingUnit = data.getString("pricingUnit", "");
            p.available   = data.getBoolean("available", true);
            p.createdAt   = data.getLong("createdAt", 0);
            super.save(p);
        }
    }

    override void createTenant(TenantId tenantId) { super.createTenant(tenantId); loadTenant(tenantId); }
    override void save(ServicePlan item)           { super.save(item); persistTenant(item.tenantId); }
    override void update(ServicePlan item)         { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId tenantId, ServicePlanId id) { super.removeById(tenantId, id); persistTenant(tenantId); }

    override ServicePlan[] findByTier(TenantId tenantId, PlanTier tier) {
        return findByTenant(tenantId).filter!(e => e.tier == tier).array;
    }

    override ServicePlan[] findAvailable(TenantId tenantId) {
        return findByTenant(tenantId).filter!(e => e.available).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(e => e.name == name);
    }
}
