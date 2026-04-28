module uim.platform.service_manager.application.usecases.manage.manage_service_plans;

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

    ServicePlan* getById(TenantId tenantId, ServicePlanId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult create(TenantId tenantId, CreateServicePlanRequest dto) {
        import std.conv : to;

        ServicePlan e;
        e.id = ServicePlanId(MonoTime.currTime.ticks.to!string);
        e.tenantId = tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.catalogName = dto.catalogName;
        e.offeringId = ServiceOfferingId(dto.offeringId);
        e.maxInstances = dto.maxInstances;
        e.schemas = dto.schemas;
        e.metadata = dto.metadata;
        e.createdAt = MonoTime.currTime.ticks;
        e.updatedAt = e.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service plan name is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult update(TenantId tenantId, ServicePlanId id, UpdateServicePlanRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service plan not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.metadata.length > 0) existing.metadata = dto.metadata;
        if (dto.schemas.length > 0) existing.schemas = dto.schemas;
        existing.maxInstances = dto.maxInstances;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(*existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(TenantId tenantId, ServicePlanId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service plan not found");

        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
