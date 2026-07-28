/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage.service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase { // TODO: UIMUseCase {
    private IServiceInstanceRepository repo;

    this(IServiceInstanceRepository repo) {
        this.repo = repo;
    }

    ServiceInstance[] listInstances(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceInstance getInstance(TenantId tenantId, ServiceInstanceId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createInstance(CreateServiceInstanceRequest dto) {
        auto instance = ServiceInstance(dto.tenantId);
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

        if (dto.name.isEmpty)
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
        auto instance = repo.findById(tenantId, id);
        if (instance.isNull)
            return CommandResult(false, "", "Service instance not found");

        repo.remove(instance);
        return CommandResult(true, instance.id.value, "");
    }
}

///
unittest {
    auto repo = new ServiceInstanceRepository();
    auto usecase = new ManageServiceInstancesUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    CreateServiceInstanceRequest createDto;
    createDto.tenantId = tenantId;
    createDto.instanceId = ServiceInstanceId("serviceInstance-1");
    createDto.name = "Test ServiceInstance";
    auto createResult = usecase.createInstance(createDto);
    // TODO: assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listInstances(tenantId);
    // TODO: assert(items.length == 1);

    // Test get
    auto item = usecase.getInstance(tenantId, ServiceInstanceId("serviceInstance-1"));
    // TODO: assert(!item.isNull);

    // Test update
    UpdateServiceInstanceRequest updateDto;
    updateDto.tenantId = tenantId;
    updateDto.instanceId = ServiceInstanceId("serviceInstance-1");
    updateDto.name = "Updated ServiceInstance";
    auto updateResult = usecase.updateInstance(updateDto);
    // TODO: assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteInstance(tenantId, ServiceInstanceId("serviceInstance-1"));
    // TODO: assert(deleteResult.success, deleteResult.message);
    // TODO: assert(usecase.listInstances(tenantId).length == 0);

}
