/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.file.metrics;

import uim.platform.redis;
import std.file   : exists, mkdirRecurse, readText, write;
import std.path   : buildPath;
import std.algorithm : filter, sort;
import std.array  : array;
import std.conv   : to;

mixin(ShowModule!());

@safe:

class FileMetricRepository
    : TenantRepository!(Metric, MetricId)
    , MetricRepository
{
    private string _basePath;
    this(string basePath) { _basePath = basePath; }

    private string filePath(TenantId tenantId) {
        return buildPath(_basePath, tenantId.value, "metrics.json");
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
        if (arr.type != Json.Type.array) return;
        foreach (j; arr.byValue()) {
            Metric m;
            m.id         = MetricId(j.getString("id", ""));
            m.tenantId   = tenantId;
            m.instanceId = ServiceInstanceId(j.getString("instanceId", ""));
            m.timestamp_ = j.getLong("timestamp", 0);
            m.memoryUsedMb  = j.getLong("memoryUsedMb", 0);
            m.memoryTotalMb = j.getLong("memoryTotalMb", 0);
            m.connectedClients = j.getLong("connectedClients", 0);
            m.commandsPerSecond = j.getLong("commandsPerSecond", 0);
            m.hitRate    = j.getDouble("hitRate", 0.0);
            m.evictedKeys = j.getLong("evictedKeys", 0);
            m.expiredKeys = j.getLong("expiredKeys", 0);
            m.totalCommandsProcessed = j.getLong("totalCommandsProcessed", 0);
            m.cpuUsagePercent = j.getDouble("cpuUsagePercent", 0.0);
            m.networkInputKbs = j.getLong("networkInputKbs", 0);
            m.networkOutputKbs = j.getLong("networkOutputKbs", 0);
            m.createdAt  = j.getLong("createdAt", 0);
            super.save(m);
        }
    }

    override void createTenant(TenantId tenantId) { super.createTenant(tenantId); loadTenant(tenantId); }
    override void save(Metric item)                { super.save(item); persistTenant(item.tenantId); }
    override void update(Metric item)              { super.update(item); persistTenant(item.tenantId); }
    override void removeById(TenantId tenantId, MetricId id) { super.removeById(tenantId, id); persistTenant(tenantId); }

    override Metric[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
    }

    override Metric[] findByInstanceAndTimeRange(TenantId tenantId, ServiceInstanceId instanceId, long from, long to_) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId && e.timestamp_ >= from && e.timestamp_ <= to_).array;
    }

    override Metric findLatestByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        auto items = findByInstance(tenantId, instanceId);
        if (items.length == 0) return Metric.init;
        Metric latest = items[0];
        foreach (m; items) if (m.timestamp_ > latest.timestamp_) latest = m;
        return latest;
    }
}
