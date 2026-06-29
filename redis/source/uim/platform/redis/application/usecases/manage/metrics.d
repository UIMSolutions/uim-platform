/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.usecases.manage.metrics;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class ManageMetricsUseCase {
    private MetricRepository repo;

    this(MetricRepository repo) { this.repo = repo; }

    Metric getMetric(TenantId tenantId, MetricId id) {
        return repo.findById(tenantId, id);
    }

    Metric[] listMetrics(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Metric[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    Metric[] listByInstanceAndTimeRange(TenantId tenantId, ServiceInstanceId instanceId, long from, long to) {
        return repo.findByInstanceAndTimeRange(tenantId, instanceId, from, to);
    }

    Metric getLatestByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findLatestByInstance(tenantId, instanceId);
    }

    CommandResult recordMetric(MetricDTO dto) {
        Metric e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.metricId;
        e.instanceId = dto.instanceId;
        e.timestamp_ = dto.timestamp_;
        e.memoryUsedMb = dto.memoryUsedMb;
        e.memoryTotalMb = dto.memoryTotalMb;
        e.connectedClients = dto.connectedClients;
        e.commandsPerSecond = dto.commandsPerSecond;
        e.hitRate = dto.hitRate;
        e.evictedKeys = dto.evictedKeys;
        e.expiredKeys = dto.expiredKeys;
        e.totalCommandsProcessed = dto.totalCommandsProcessed;
        e.cpuUsagePercent = dto.cpuUsagePercent;
        e.networkInputKbs = dto.networkInputKbs;
        e.networkOutputKbs = dto.networkOutputKbs;

        if (!RedisValidator.isValidMetric(e))
            return CommandResult(false, "", "Invalid metric: instanceId and timestamp required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult deleteMetric(TenantId tenantId, MetricId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Metric not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
