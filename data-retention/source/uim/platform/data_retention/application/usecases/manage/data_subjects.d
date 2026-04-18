module uim.platform.data_retention.application.usecases.manage.data_subjects;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDataSubjectsUseCase : UIMUseCase {
    private DataSubjectRepository repo;

    this(DataSubjectRepository repo) { this.repo = repo; }

    CommandResult create(CreateDataSubjectRequest req) {
        import std.uuid : randomUUID;
        if (req.externalId.length == 0) return CommandResult(false, "", "External ID is required");

        DataSubject ds;
        ds.id = DataSubjectId(randomUUID().toString());
        ds.tenantId = req.tenantId;
        ds.roleId = DataSubjectRoleId(req.roleId);
        ds.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        ds.externalId = req.externalId;
        ds.lifecycleStatus = DataLifecycleStatus.active;
        ds.createdBy = req.createdBy;
        ds.createdAt = clockSeconds();

        repo.save(ds);
        return CommandResult(true, ds.id.value, "");
    }

    CommandResult update(string id, UpdateDataSubjectRequest req) { return update(DataSubjectId(id), req); }

    CommandResult update(DataSubjectId id, UpdateDataSubjectRequest req) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Data subject not found");

        auto ds = repo.findById(id);
        if (req.lifecycleStatus.length > 0) ds.lifecycleStatus = parseLifecycleStatus(req.lifecycleStatus);
        if (req.roleId.length > 0) ds.roleId = DataSubjectRoleId(req.roleId);
        ds.updatedAt = clockSeconds();

        repo.update(ds);
        return CommandResult(true, id.value, "");
    }

    CommandResult block(string id) { return block(DataSubjectId(id)); }

    CommandResult block(DataSubjectId id) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Data subject not found");
        auto ds = repo.findById(id);
        ds.lifecycleStatus = DataLifecycleStatus.blocked;
        ds.blockedAt = clockSeconds();
        ds.updatedAt = clockSeconds();
        repo.update(ds);
        return CommandResult(true, id.value, "");
    }

    bool hasById(string id) { return hasById(DataSubjectId(id)); }
    bool hasById(DataSubjectId id) { return repo.existsById(id); }
    DataSubject getById(string id) { return getById(DataSubjectId(id)); }
    DataSubject getById(DataSubjectId id) { return repo.findById(id); }
    DataSubject[] list(string tenantId) { return list(TenantId(tenantId)); }
    DataSubject[] list(TenantId tenantId) { return repo.findAll(tenantId); }
    DataSubject[] listByStatus(TenantId tenantId, DataLifecycleStatus status) {
        return repo.findByLifecycleStatus(tenantId, status);
    }
    CommandResult remove(string id) { return remove(DataSubjectId(id)); }
    CommandResult remove(DataSubjectId id) { repo.remove(id); return CommandResult(true, id.value, ""); }

    private static DataLifecycleStatus parseLifecycleStatus(string s) {
        switch (s) {
            case "active": return DataLifecycleStatus.active;
            case "blocked": return DataLifecycleStatus.blocked;
            case "markedForDeletion": return DataLifecycleStatus.markedForDeletion;
            case "deleted": return DataLifecycleStatus.deleted;
            case "archived": return DataLifecycleStatus.archived;
            default: return DataLifecycleStatus.active;
        }
    }
}
