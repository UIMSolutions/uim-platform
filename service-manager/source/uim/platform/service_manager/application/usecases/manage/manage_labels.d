module uim.platform.service_manager.application.usecases.manage.manage_labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageLabelsUseCase { // TODO: UIMUseCase {
    private LabelRepository repo;

    this(LabelRepository repo) {
        this.repo = repo;
    }

    Label[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Label* getById(TenantId tenantId, LabelId id) {
        return repo.findById(tenantId, id);
    }

    Label[] listByResource(TenantId tenantId, string resourceType, string resourceId) {
        return repo.findByResource(tenantId, resourceType, resourceId);
    }

    CommandResult create(TenantId tenantId, CreateLabelRequest dto) {
        import std.conv : to;

        Label e;
        e.id = LabelId(MonoTime.currTime.ticks.to!string);
        e.tenantId = tenantId;
        e.resourceId = dto.resourceId;
        e.resourceType = dto.resourceType;
        e.key = dto.key;
        e.value = dto.value;
        e.createdAt = MonoTime.currTime.ticks;

        if (dto.key.length == 0)
            return CommandResult(false, "", "Label key is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult update(TenantId tenantId, LabelId id, UpdateLabelRequest dto) {
        auto existing = repo.findById(tenantId, id);
        if (existing is null)
            return CommandResult(false, "", "Label not found");

        if (dto.key.length > 0) existing.key = dto.key;
        if (dto.value.length > 0) existing.value = dto.value;

        repo.update(*existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(TenantId tenantId, LabelId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing is null)
            return CommandResult(false, "", "Label not found");

        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
