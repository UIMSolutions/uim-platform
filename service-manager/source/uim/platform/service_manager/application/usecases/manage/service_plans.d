module uim.platform.service_manager.application.usecases.manage.service_plans;

import uim.platform.service_manager;

// mixin(ShowModule!());

@safe:

class ManageServicePlansUseCase { // TODO: UIMUseCase {
    private ServicePlanRepository repo;

    this(ServicePlanRepository repo) {
        this.repo = repo;
    }

    ServicePlan[] listPlans(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ServicePlan getPlan(TenantId tenantId, ServicePlanId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createPlan(CreateServicePlanRequest dto) {
        auto plan = ServicePlan(dto.tenantId);

        plan.id = ServicePlanId(currentTimestamp.to!string);
        plan.tenantId = dto.tenantId;
        plan.name = dto.name;
        plan.description = dto.description;
        plan.catalogName = dto.catalogName;
        plan.offeringId = dto.offeringId;
        plan.maxInstances = dto.maxInstances;
        plan.schemas = dto.schemas;
        plan.metadata = dto.metadata;
        plan.createdAt = currentTimestamp;
        plan.updatedAt = plan.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service plan name is required");

        repo.save(plan);
        return CommandResult(true, plan.id.value, "");
    }

    CommandResult updatePlan(UpdateServicePlanRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.planId);
        if (existing.isNull)
            return CommandResult(false, "", "Service plan not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.metadata.length > 0) existing.metadata = dto.metadata;
        if (dto.schemas.length > 0) existing.schemas = dto.schemas;
        existing.maxInstances = dto.maxInstances;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deletePlan(TenantId tenantId, ServicePlanId id) {
        auto plan = repo.findById(tenantId, id);
        if (plan.isNull)
            return CommandResult(false, "", "Service plan not found");

        repo.remove(plan);
        return CommandResult(true, plan.id.value, "");
    }
}
