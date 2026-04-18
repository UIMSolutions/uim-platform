module uim.platform.service_manager.application.usecases.manage.manage_service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase : UIMUseCase {
    private ServiceInstanceRepository repo;

    this(ServiceInstanceRepository repo) {
        this.repo = repo;
    }

    ServiceInstance[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceInstance* getById(TenantId tenantId, ServiceInstanceId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult create(TenantId tenantId, CreateServiceInstanceRequest dto) {
        import std.conv : to;

        ServiceInstance e;
        e.id = ServiceInstanceId(MonoTime.currTime.ticks.to!string);
        e.tenantId = tenantId;
        e.name = dto.name;
        e.planId = ServicePlanId(dto.planId);
        e.offeringId = ServiceOfferingId(dto.offeringId);
        e.platformId = PlatformId(dto.platformId);
        e.context = dto.context;
        e.parameters = dto.parameters;
        e.labels = dto.labels;
        e.status = ServiceInstanceStatus.creating;
        e.createdAt = MonoTime.currTime.ticks;
        e.updatedAt = e.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service instance name is required");
        if (dto.planId.length == 0)
            return CommandResult(false, "", "Service plan ID is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult update(TenantId tenantId, ServiceInstanceId id, UpdateServiceInstanceRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing is null)
            return CommandResult(false, "", "Service instance not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.planId.length > 0) existing.planId = ServicePlanId(dto.planId);
        if (dto.parameters.length > 0) existing.parameters = dto.parameters;
        if (dto.labels.length > 0) existing.labels = dto.labels;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(*existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(TenantId tenantId, ServiceInstanceId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing is null)
            return CommandResult(false, "", "Service instance not found");

        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
