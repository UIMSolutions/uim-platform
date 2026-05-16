module uim.platform.service_manager.application.usecases.manage.labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageLabelsUseCase { // TODO: UIMUseCase {
    private LabelRepository repo;

    this(LabelRepository repo) {
        this.repo = repo;
    }

    Label[] listLabels(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Label getLabel(TenantId tenantId, LabelId id) {
        return repo.findById(tenantId, id);
    }

    Label[] listLabels(TenantId tenantId, string resourceType, string resourceId) {
        return repo.findByResource(tenantId, resourceType, resourceId);
    }

    CommandResult createLabel(TenantId tenantId, CreateLabelRequest dto) {
        Label e;
        e.id = LabelId(currentTimestamp.to!string);
        e.tenantId = tenantId;
        e.resourceId = dto.resourceId;
        e.resourceType = dto.resourceType;
        e.key = dto.key;
        e.value = dto.value;
        e.createdAt = currentTimestamp;

        if (dto.key.length == 0)
            return CommandResult(false, "", "Label key is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateLabel(UpdateLabelRequest dto) {
        auto existing = repo.findById(dto.tenantId, LabelId(dto.id));
        if (existing.isNull)
            return CommandResult(false, "", "Label not found");

        if (dto.key.length > 0)
            existing.key = dto.key;
        if (dto.value.length > 0)
            existing.value = dto.value;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteLabel(TenantId tenantId, LabelId id) {
        auto label = repo.findById(tenantId, id);
        if (label.isNull)
            return CommandResult(false, "", "Label not found");

        repo.remove(label);
        return CommandResult(true, label.id.value, "");
    }
}
