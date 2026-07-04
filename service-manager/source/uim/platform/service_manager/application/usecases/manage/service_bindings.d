module uim.platform.service_manager.application.usecases.manage.service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
    private ServiceBindingRepository repo;

    this(ServiceBindingRepository repo) {
        this.repo = repo;
    }

    ServiceBinding[] listBindings(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceBinding getBinding(TenantId tenantId, ServiceBindingId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createBinding(CreateServiceBindingRequest dto) {

        auto binding = ServiceBinding(dto.tenantId);
        binding.name = dto.name;
        binding.id = ServiceBindingId(currentTimestamp.to!string);
        binding.tenantId = dto.tenantId;
        binding.name = dto.name;
        binding.instanceId = dto.instanceId;
        binding.parameters = dto.parameters;
        binding.bindResource = dto.bindResource;
        binding.context = dto.context;
        binding.labels = dto.labels;
        binding.status = ServiceBindingStatus.creating;
        binding.createdAt = currentTimestamp;
        binding.updatedAt = binding.createdAt;

        if (dto.name.length == 0)
            return CommandResult(false, "", "Service binding name is required");
        if (dto.instanceId.isNull)
            return CommandResult(false, "", "Service instance ID is required");

        repo.save(binding);
        return CommandResult(true, binding.id.value, "");
    }

    CommandResult updateBinding(UpdateServiceBindingRequest dto) {
        auto binding = repo.findById(dto.tenantId, dto.bindingId);
        if (binding.isNull)
            return CommandResult(false, "", "Service binding not found");

        if (dto.name.length > 0) binding.name = dto.name;
        if (dto.parameters.length > 0) binding.parameters = dto.parameters;
        if (dto.labels.length > 0) binding.labels = dto.labels;
        binding.updatedAt = currentTimestamp;

        repo.update(binding);
        return CommandResult(true, binding.id.value, "");
    }

    CommandResult deleteBinding(TenantId tenantId, ServiceBindingId id) {
        auto binding = repo.findById(tenantId, id);
        if (binding.isNull)
            return CommandResult(false, "", "Service binding not found");

        repo.remove(binding);
        return CommandResult(true, binding.id.value, "");
    }
}
