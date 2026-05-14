module uim.platform.service_manager.application.usecases.manage.service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
    private ServiceBindingRepository repo;

    this(ServiceBindingRepository repo) {
        this.repo = repo;
    }

    ServiceBinding[] listServiceBindings(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createServiceBinding(CreateServiceBindingRequest dto) {

        ServiceBinding e;
        e.id = ServiceBindingId(MonoTime.currTime.ticks.to!string);
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.instanceId = ServiceInstanceId(dto.instanceId);
        e.parameters = dto.parameters;
        e.bindResource = dto.bindResource;
        e.context = dto.context;
        e.labels = dto.labels;
        e.status = ServiceBindingStatus.creating;
        e.createdAt = MonoTime.currTime.ticks;
        e.updatedAt = e.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service binding name is required");
        if (dto.instanceId.length == 0)
            return CommandResult(false, "", "Service instance ID is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServiceBinding(TenantId tenantId, ServiceBindingId id, UpdateServiceBindingRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service binding not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.parameters.length > 0) existing.parameters = dto.parameters;
        if (dto.labels.length > 0) existing.labels = dto.labels;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult deleteServiceBinding(TenantId tenantId, ServiceBindingId id) {
        auto binding = repo.findById(tenantId, id);
        if (binding.isNull)
            return CommandResult(false, "", "Service binding not found");

        repo.remove(binding);
        return CommandResult(true, binding.id.value, "");
    }
}
