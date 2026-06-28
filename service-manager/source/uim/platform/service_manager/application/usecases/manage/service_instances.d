module uim.platform.service_manager.application.usecases.manage.service_instances;

import uim.platform.service_manager;

// mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase { // TODO: UIMUseCase {
    private ServiceInstanceRepository repo;

    this(ServiceInstanceRepository repo) {
        this.repo = repo;
    }

    ServiceInstance[] listInstances(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ServiceInstance getInstance(TenantId tenantId, ServiceInstanceId id) {
        return repo.find(tenantId, id);
    }

    CommandResult createInstance(CreateServiceInstanceRequest dto) {
        auto instance = ServiceInstance(dto.tenantId);
        instance.initEntity(dto.tenantId);

        instance.id = ServiceInstanceId(currentTimestamp.to!string);
        instance.tenantId = dto.tenantId;
        instance.name = dto.name;
        instance.planId = dto.planId;
        instance.offeringId = dto.offeringId;
        instance.platformId = dto.platformId;
        instance.context = dto.context;
        instance.parameters = dto.parameters;
        instance.labels = dto.labels;
        instance.status = ServiceInstanceStatus.creating;
        instance.createdAt = currentTimestamp;
        instance.updatedAt = instance.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service instance name is required");

        if (dto.planId.isNull)
            return CommandResult(false, "", "Service plan ID is required");

        repo.save(instance);
        return CommandResult(true, instance.id.value, "");
    }

    CommandResult updateInstance(UpdateServiceInstanceRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.instanceId);
        if (existing.isNull)
            return CommandResult(false, "", "Service instance not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (!dto.planId.isNull) existing.planId = dto.planId;
        if (dto.parameters.length > 0) existing.parameters = dto.parameters;
        if (dto.labels.length > 0) existing.labels = dto.labels;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteInstance(TenantId tenantId, ServiceInstanceId id) {
        auto instance = repo.find(tenantId, id);
        if (instance.isNull)
            return CommandResult(false, "", "Service instance not found");

        repo.remove(instance);
        return CommandResult(true, instance.id.value, "");
    }
}
