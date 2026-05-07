module uim.platform.data_retention.application.usecases.manage.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDataSubjectRolesUseCase { // TODO: UIMUseCase {
    private DataSubjectRoleRepository repo;

    this(DataSubjectRoleRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateDataSubjectRoleRequest req) {
        import std.uuid : randomUUID;

        if (req.name.length == 0)
            return CommandResult(false, "", "Data subject role name is required");

        DataSubjectRole dsr;
        dsr.id = DataSubjectRoleId(randomUUID().toString());
        dsr.tenantId = req.tenantId;
        dsr.name = req.name;
        dsr.description = req.description;
        dsr.isActive = true;
        dsr.createdBy = req.createdBy;
        dsr.createdAt = clockSeconds();

        repo.save(dsr);
        return CommandResult(true, dsr.id.value, "");
    }

    CommandResult update(string id, UpdateDataSubjectRoleRequest req) {
        return update(DataSubjectRoleId(id), req);
    }

    CommandResult update(DataSubjectRoleId id, UpdateDataSubjectRoleRequest req) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Data subject role not found");

        auto dsr = repo.findById(tenantId, id);
        if (req.name.length > 0)
            dsr.name = req.name;
        if (req.description.length > 0)
            dsr.description = req.description;
        dsr.isActive = req.isActive;
        dsr.updatedAt = clockSeconds();

        repo.update(dsr);
        return CommandResult(true, id.value, "");
    }

    bool hasById(DataSubjectRoleId id) {
        return repo.existsById(id);
    }

    DataSubjectRole getById(DataSubjectRoleId id) {
        return repo.findById(tenantId, id);
    }

    DataSubjectRole[] list(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    CommandResult deleteDataSubjectRole(DataSubjectRoleId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Data subject role not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
