module uim.platform.service_manager.application.usecases.manage.service_plans;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServicePlansUseCase { // TODO: UIMUseCase {
    private ServicePlanRepository repo;

    this(ServicePlanRepository repo) {
        this.repo = repo;
    }

    ServicePlan[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServicePlan getById(TenantId tenantId, ServicePlanId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createServicePlan(CreateServicePlanRequest dto) {
        ServicePlan e;
        e.initEntity(TenantId(dto.tenantId), dto.createdBy);

        e.id = ServicePlanId(currentTimestamp.to!string);
        e.tenantId = TenantId(dto.tenantId);
        e.name = dto.name;
        e.description = dto.description;
        e.catalogName = dto.catalogName;
        e.offeringId = ServiceOfferingId(dto.offeringId);
        e.maxInstances = dto.maxInstances;
        e.schemas = dto.schemas;
        e.metadata = dto.metadata;
        e.createdAt = currentTimestamp;
        e.updatedAt = e.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service plan name is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServicePlan(UpdateServicePlanRequest dto) {
        auto existing = repo.findById(TenantId(dto.tenantId), ServicePlanId(dto.id));
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

    CommandResult deleteServicePlan(TenantId tenantId, ServicePlanId id) {
        auto plan = repo.findById(tenantId, id);
        if (plan.isNull)
            return CommandResult(false, "", "Service plan not found");

        repo.remove(plan);
        return CommandResult(true, plan.id.value, "");
    }
}
