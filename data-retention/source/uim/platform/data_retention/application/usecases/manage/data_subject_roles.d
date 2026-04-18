module uim.platform.data_retention.application.usecases.manage.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDataSubjectRolesUseCase : UIMUseCase {
    private DataSubjectRoleRepository repo;

    this(DataSubjectRoleRepository repo) { this.repo = repo; }

    CommandResult create(CreateDataSubjectRoleRequest req) {
        import std.uuid : randomUUID;
        if (req.name.length == 0) return CommandResult(false, "", "Data subject role name is required");

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

    CommandResult update(string id, UpdateDataSubjectRoleRequest req) { return update(DataSubjectRoleId(id), req); }

    CommandResult update(DataSubjectRoleId id, UpdateDataSubjectRoleRequest req) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Data subject role not found");

        auto dsr = repo.findById(id);
        if (req.name.length > 0) dsr.name = req.name;
        if (req.description.length > 0) dsr.description = req.description;
        dsr.isActive = req.isActive;
        dsr.updatedAt = clockSeconds();

        repo.update(dsr);
        return CommandResult(true, id.value, "");
    }

    bool hasById(string id) { return hasById(DataSubjectRoleId(id)); }
    bool hasById(DataSubjectRoleId id) { return repo.existsById(id); }
    DataSubjectRole getById(string id) { return getById(DataSubjectRoleId(id)); }
    DataSubjectRole getById(DataSubjectRoleId id) { return repo.findById(id); }
    DataSubjectRole[] list(string tenantId) { return list(TenantId(tenantId)); }
    DataSubjectRole[] list(TenantId tenantId) { return repo.findAll(tenantId); }
    CommandResult remove(string id) { return remove(DataSubjectRoleId(id)); }
    CommandResult remove(DataSubjectRoleId id) { repo.remove(id); return CommandResult(true, id.value, ""); }
}
