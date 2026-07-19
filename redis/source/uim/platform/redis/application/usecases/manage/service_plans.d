/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.usecases.manage.service_plans;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class ManageServicePlansUseCase {
    private ServicePlanRepository repo;

    this(ServicePlanRepository repo) { this.repo = repo; }

    ServicePlan getServicePlan(TenantId tenantId, ServicePlanId id) {
        return repo.findById(tenantId, id);
    }

    ServicePlan[] listServicePlans(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServicePlan[] listAvailable(TenantId tenantId) {
        return repo.findAvailable(tenantId);
    }

    ServicePlan[] listByTier(TenantId tenantId, PlanTier tier) {
        return repo.findByTier(tenantId, tier);
    }

    CommandResult createServicePlan(ServicePlanDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Service plan name already exists");

        auto e = ServicePlan(dto.tenantId, dto.servicePlanId, dto.createdBy);
        e.name = dto.name;
        e.description = dto.description;
        e.tier = dto.tier;
        e.memoryMb = dto.memoryMb;
        e.maxConnections = dto.maxConnections;
        e.haEnabled = dto.haEnabled;
        e.persistenceEnabled = dto.persistenceEnabled;
        e.tlsEnabled = dto.tlsEnabled;
        e.pricingUnit = dto.pricingUnit;
        e.available = dto.available;

        if (!RedisValidator.isValidServicePlan(e))
            return CommandResult(false, "", "Invalid plan: name and memoryMb > 0 required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServicePlan(ServicePlanDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.servicePlanId);
        if (existing.isNull)
            return CommandResult(false, "", "Service plan not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.memoryMb > 0) existing.memoryMb = dto.memoryMb;
        if (dto.pricingUnit.length > 0) existing.pricingUnit = dto.pricingUnit;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServicePlan(TenantId tenantId, ServicePlanId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service plan not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
