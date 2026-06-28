/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.usecases.manage.service_plans;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class ManageServicePlansUseCase {
    private ServicePlanRepository repo;

    this(ServicePlanRepository repo) { this.repo = repo; }

    ServicePlan getServicePlan(TenantId tenantId, ServicePlanId id) {
        return repo.findById(tenantId, id);
    }

    ServicePlan[] listServicePlans(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ServicePlan[] listAvailable(TenantId tenantId) {
        return repo.findAvailable(tenantId);
    }

    CommandResult createServicePlan(ServicePlanDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Plan name already exists");

        ServicePlan e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.servicePlanId;
        e.name = dto.name;
        e.description = dto.description;
        e.tier = dto.tier;
        e.memoryGb = dto.memoryGb;
        e.storageGb = dto.storageGb;
        e.maxConnections = dto.maxConnections;
        e.multiAzSupported = dto.multiAzSupported;
        e.available = dto.available;
        e.pricingUnit = dto.pricingUnit;

        if (e.name.length == 0)
            return CommandResult(false, "", "name is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServicePlan(ServicePlanDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.servicePlanId);
        if (existing.isNull)
            return CommandResult(false, "", "Plan not found");
        if (dto.description.length > 0) existing.description = dto.description;
        existing.available = dto.available;
        if (dto.memoryGb > 0) existing.memoryGb = dto.memoryGb;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServicePlan(TenantId tenantId, ServicePlanId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Plan not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
