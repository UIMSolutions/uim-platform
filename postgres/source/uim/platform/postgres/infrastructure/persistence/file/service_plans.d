/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.file.service_plans;

import uim.platform.postgres;
import std.file     : exists, mkdirRecurse, readText, write;
import std.path     : buildPath;
import std.algorithm : filter, any;
import std.array    : array;
import std.conv     : to;
import std.string   : lastIndexOf;
mixin(ShowModule!());

@safe:

class FileServicePlanRepository
    : TenantRepository!(ServicePlan, ServicePlanId)
    , ServicePlanRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId t) {
        return buildPath(_basePath, t.value, "service_plans.json");
    }

    private void persistTenant(TenantId t) @trusted {
        auto path = filePath(t);
        mkdirRecurse(path[0 .. path.lastIndexOf('/')]);
        Json arr = Json.emptyArray;
        foreach (i; findByTenant(t)) arr ~= i.toJson();
        write(path, arr.toString());
    }

    private void loadTenant(TenantId t) @trusted {
        auto path = filePath(t);
        if (!exists(path)) return;
        auto arr = parseJson(readText(path));
        if (!arr.isArray) return;
        foreach (j; arr.byValue()) {
            ServicePlan e;
            e.id               = ServicePlanId(data.getString("id", ""));
            e.tenantId         = t;
            e.name             = data.getString("name", "");
            e.description      = data.getString("description", "");
            e.tier             = data.getString("tier", "standard").to!PlanTier;
            e.memoryGb         = data.getLong("memoryGb", 4);
            e.storageGb        = data.getLong("storageGb", 20);
            e.maxConnections   = data.getLong("maxConnections", 100);
            e.multiAzSupported = data.getBoolean("multiAzSupported", false);
            e.available        = data.getBoolean("available", true);
            e.pricingUnit      = data.getString("pricingUnit", "");
            e.createdAt        = data.getLong("createdAt", 0);
            e.createdBy        = UserId(data.getString("createdBy", ""));
            e.updatedBy        = UserId(data.getString("updatedBy", ""));
            super.save(e);
        }
    }

    override void createTenant(TenantId t) { super.createTenant(t); loadTenant(t); }
    override void save(ServicePlan item)    { super.save(item); persistTenant(item.tenantId); }
    override void update(ServicePlan item)  { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId t, ServicePlanId id) { super.removeById(t, id); persistTenant(t); }

    override ServicePlan[] findByTier(TenantId t, PlanTier tier) {
        return findByTenant(t).filter!(e => e.tier == tier).array;
    }
    override ServicePlan[] findAvailable(TenantId t) {
        return findByTenant(t).filter!(e => e.available).array;
    }
    override bool nameExists(TenantId t, string name) {
        return findByTenant(t).any!(e => e.name == name);
    }
}
