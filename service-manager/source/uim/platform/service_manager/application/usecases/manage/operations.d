module uim.platform.service_manager.application.usecases.manage.operations;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageOperationsUseCase {
    private IOperationRepository repo;

    this(IOperationRepository repo) {
        this.repo = repo;
    }

    Operation[] listOperations(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Operation getOperation(TenantId tenantId, OperationId id) {
        return repo.findById(tenantId, id);
    }

    UsecaseResult createOperation(CreateOperationRequest dto) {
        auto e = Operation(dto.tenantId);
        e.id = OperationId(currentTimestamp.to!string);
        e.resourceId = dto.resourceId;
        e.resourceType = dto.resourceType;
        e.description = dto.description;
        e.status = OperationStatus.pending;
        e.createdAt = currentTimestamp;

        repo.save(e);
        return UsecaseResult(true, e.id.value, "");
    }

    UsecaseResult updateOperation(UpdateOperationRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.operationId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Operation not found");

        if (dto.errorMessage.length > 0) existing.errorMessage = dto.errorMessage;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteOperation(TenantId tenantId, OperationId id) {
        auto operation = repo.findById(tenantId, id);
        if (operation.isNull)
            return UsecaseResult(false, "", "Operation not found");

        repo.remove(operation);
        return UsecaseResult(true, operation.id.value, "");
    }
}

///
unittest {
    auto repo = new OperationRepository();
    auto usecase = new ManageOperationsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    CreateOperationRequest createDto;
    createDto.tenantId = tenantId;
    createDto.operationId = OperationId("operation-1");
    // createDto.name = "Test Operation";
    auto createResult = usecase.createOperation(createDto);
    // TODO: assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listOperations(tenantId);
    // TODO: assert(items.length == 1);

    // Test get
    auto item = usecase.getOperation(tenantId, OperationId("operation-1"));
    // TODOD: assert(!item.isNull);

    // Test update
    UpdateOperationRequest updateDto;
    updateDto.tenantId = tenantId;
    updateDto.operationId = OperationId("operation-1");
    // updateDto.name = "Updated Operation";
    auto updateResult = usecase.updateOperation(updateDto);
    // TODO: assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteOperation(tenantId, OperationId("operation-1"));
    // TODO: assert(deleteResult.success, deleteResult.message);
    // TODO: assert(usecase.listOperations(tenantId).length == 0);

}
