module uim.platform.service_manager.application.usecases.manage.service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase {
    private IServiceBindingRepository repo;

    this(IServiceBindingRepository repo) {
        this.repo = repo;
    }

    ServiceBinding[] listBindings(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceBinding getBinding(TenantId tenantId, ServiceBindingId id) {
        return repo.findById(tenantId, id);
    }

    UsecaseResult createBinding(CreateServiceBindingRequest dto) {

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

        if (dto.name.isEmpty)
            return UsecaseResult(false, "", "Service binding name is required");
        if (dto.instanceId.isNull)
            return UsecaseResult(false, "", "Service instance ID is required");

        repo.save(binding);
        return UsecaseResult(true, binding.id.value, "");
    }

    UsecaseResult updateBinding(UpdateServiceBindingRequest dto) {
        auto binding = repo.findById(dto.tenantId, dto.bindingId);
        if (binding.isNull)
            return UsecaseResult(false, "", "Service binding not found");

        if (dto.name.length > 0) binding.name = dto.name;
        if (dto.parameters.length > 0) binding.parameters = dto.parameters;
        if (dto.labels.length > 0) binding.labels = dto.labels;
        binding.updatedAt = currentTimestamp;

        repo.update(binding);
        return UsecaseResult(true, binding.id.value, "");
    }

    UsecaseResult deleteBinding(TenantId tenantId, ServiceBindingId id) {
        auto binding = repo.findById(tenantId, id);
        if (binding.isNull)
            return UsecaseResult(false, "", "Service binding not found");

        repo.remove(binding);
        return UsecaseResult(true, binding.id.value, "");
    }
}

///
unittest {
    auto repo = new ServiceBindingRepository();
    auto usecase = new ManageServiceBindingsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    CreateServiceBindingRequest createDto;
    createDto.tenantId = tenantId;
    createDto.bindingId = ServiceBindingId("serviceBinding-1");
    createDto.name = "Test ServiceBinding";
    auto createResult = usecase.createBinding(createDto);
    // TODO: assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listBindings(tenantId);
    // TODO: assert(items.length == 1);

    // Test get
    auto item = usecase.getBinding(tenantId, ServiceBindingId("serviceBinding-1"));
    // TODO: assert(!item.isNull);

    // Test update
    UpdateServiceBindingRequest updateDto;
    updateDto.tenantId = tenantId;
    updateDto.bindingId = ServiceBindingId("serviceBinding-1");
    updateDto.name = "Updated ServiceBinding";
    auto updateResult = usecase.updateBinding(updateDto);
    // TODO: assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteBinding(tenantId, ServiceBindingId("serviceBinding-1"));
    // TODO: assert(deleteResult.success, deleteResult.message);
    // TODO: assert(usecase.listBindings(tenantId).length == 0);

}
