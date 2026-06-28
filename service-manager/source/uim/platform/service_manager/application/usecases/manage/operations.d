module uim.platform.service_manager.application.usecases.manage.operations;

import uim.platform.service_manager;

// mixin(ShowModule!());

@safe:

class ManageOperationsUseCase { // TODO: UIMUseCase {
    private OperationRepository repo;

    this(OperationRepository repo) {
        this.repo = repo;
    }

    Operation[] listOperations(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Operation getOperation(TenantId tenantId, OperationId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createOperation(CreateOperationRequest dto) {
        Operation e;
        e.initEntity(dto.tenantId);

        e.id = OperationId(currentTimestamp.to!string);
        e.resourceId = dto.resourceId;
        e.resourceType = dto.resourceType;
        e.description = dto.description;
        e.status = OperationStatus.pending;
        e.createdAt = currentTimestamp;

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateOperation(UpdateOperationRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.operationId);
        if (existing.isNull)
            return CommandResult(false, "", "Operation not found");

        if (dto.errorMessage.length > 0) existing.errorMessage = dto.errorMessage;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteOperation(TenantId tenantId, OperationId id) {
        auto operation = repo.findById(tenantId, id);
        if (operation.isNull)
            return CommandResult(false, "", "Operation not found");

        repo.remove(operation);
        return CommandResult(true, operation.id.value, "");
    }
}
