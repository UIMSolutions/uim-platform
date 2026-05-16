module uim.platform.service_manager.application.usecases.manage.service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase { // TODO: UIMUseCase {
    private ServiceInstanceRepository repo;

    this(ServiceInstanceRepository repo) {
        this.repo = repo;
    }

    ServiceInstance[] listServiceInstances(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceInstance getServiceInstance(TenantId tenantId, ServiceInstanceId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createServiceInstance(TenantId tenantId, CreateServiceInstanceRequest dto) {
        ServiceInstance e;
        e.initEntity(tenantId);

        e.id = ServiceInstanceId(currentTimestamp.to!string);
        e.tenantId = tenantId;
        e.name = dto.name;
        e.planId = ServicePlanId(dto.planId);
        e.offeringId = ServiceOfferingId(dto.offeringId);
        e.platformId = PlatformId(dto.platformId);
        e.context = dto.context;
        e.parameters = dto.parameters;
        e.labels = dto.labels;
        e.status = ServiceInstanceStatus.creating;
        e.createdAt = currentTimestamp;
        e.updatedAt = e.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service instance name is required");
        if (dto.planId.length == 0)
            return CommandResult(false, "", "Service plan ID is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServiceInstance(UpdateServiceInstanceRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.id);
        if (existing.isNull)
            return CommandResult(false, "", "Service instance not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.planId.length > 0) existing.planId = ServicePlanId(dto.planId);
        if (dto.parameters.length > 0) existing.parameters = dto.parameters;
        if (dto.labels.length > 0) existing.labels = dto.labels;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServiceInstance(TenantId tenantId, ServiceInstanceId id) {
        auto instance = repo.findById(tenantId, id);
        if (instance.isNull)
            return CommandResult(false, "", "Service instance not found");

        repo.remove(instance);
        return CommandResult(true, instance.id.value, "");
    }
}
