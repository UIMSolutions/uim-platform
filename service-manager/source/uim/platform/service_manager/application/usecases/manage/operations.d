module uim.platform.service_manager.application.usecases.manage.operations;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageOperationsUseCase { // TODO: UIMUseCase {
    private OperationRepository repo;

    this(OperationRepository repo) {
        this.repo = repo;
    }

    Operation[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Operation getById(TenantId tenantId, OperationId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult create(TenantId tenantId, CreateOperationRequest dto) {
        

        Operation e;
        e.id = OperationId(MonoTime.currTime.ticks.to!string);
        e.tenantId = tenantId;
        e.resourceId = dto.resourceId;
        e.resourceType = dto.resourceType;
        e.description = dto.description;
        e.status = OperationStatus.pending;
        e.createdAt = MonoTime.currTime.ticks;
        e.updatedAt = e.createdAt;

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult update(TenantId tenantId, OperationId id, UpdateOperationRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Operation not found");

        if (dto.errorMessage.length > 0) existing.errorMessage = dto.errorMessage;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult deleteOperation(TenantId tenantId, OperationId id) {
        auto operation = repo.findById(tenantId, id);
        if (operation.isNull)
            return CommandResult(false, "", "Operation not found");

        repo.remove(operation);
        return CommandResult(true, operation.id.value, "");
    }
}
