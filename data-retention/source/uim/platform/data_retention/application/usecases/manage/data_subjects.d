module uim.platform.data_retention.application.usecases.manage.data_subjects;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDataSubjectsUseCase { // TODO: UIMUseCase {
    private DataSubjectRepository repo;

    this(DataSubjectRepository repo) {
        this.repo = repo;
    }

    CommandResult createDataSubject(CreateDataSubjectRequest req) {
        import std.uuid : randomUUID;

        if (req.externalId.length == 0)
            return CommandResult(false, "", "External ID is required");

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

    CommandResult updateDataSubject(DataSubjectId id, UpdateDataSubjectRequest req) {
        auto ds = repo.findById(tenantId, id);
        if (ds.isNull)
            return CommandResult(false, "", "Data subject not found");

        if (req.lifecycleStatus.length > 0)
            ds.lifecycleStatus = parseLifecycleStatus(req.lifecycleStatus);
        if (req.roleId.length > 0)
            ds.roleId = DataSubjectRoleId(req.roleId);
        ds.updatedAt = clockSeconds();

        repo.update(ds);
        return CommandResult(true, id.value, "");
    }

    CommandResult blockDataSubject(DataSubjectId id) {
        auto ds = repo.findById(tenantId, id);
        if (ds.isNull)
            return CommandResult(false, "", "Data subject not found");

        ds.lifecycleStatus = DataLifecycleStatus.blocked;
        ds.blockedAt = clockSeconds();
        ds.updatedAt = clockSeconds();
        repo.update(ds);
        return CommandResult(true, id.value, "");
    }

    bool hasDataSubjectById(DataSubjectId id) {
        return repo.existsById(id);
    }

    DataSubject getDataSubjectById(DataSubjectId id) {
        return repo.findById(tenantId, id);
    }

    DataSubject[] listDataSubjects(TenantId tenantId) {
        return repo.findAll(tenantId);
    }

    DataSubject[] listDataSubjects(TenantId tenantId, DataLifecycleStatus status) {
        return repo.findByLifecycleStatus(tenantId, status);
    }

    CommandResult deleteDataSubject(DataSubjectId id) {
        auto subject = repo.findById(tenantId, id);
        if (subject.isNull)
            return CommandResult(false, "", "Data subject not found");

        repo.remove(subject);
        return CommandResult(true, subject.id.value, "");
    }

    private static DataLifecycleStatus parseLifecycleStatus(string s) {
        switch (s) {
        case "active":
            return DataLifecycleStatus.active;
        case "blocked":
            return DataLifecycleStatus.blocked;
        case "markedForDeletion":
            return DataLifecycleStatus.markedForDeletion;
        case "deleted":
            return DataLifecycleStatus.deleted;
        case "archived":
            return DataLifecycleStatus.archived;
        default:
            return DataLifecycleStatus.active;
        }
    }
}
