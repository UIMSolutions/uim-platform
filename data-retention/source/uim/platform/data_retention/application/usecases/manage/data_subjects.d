module uim.platform.data_retention.application.usecases.manage.data_subjects;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

class ManageDataSubjectsUseCase { // TODO: UIMUseCase {
    private DataSubjectRepository repo;

    this(DataSubjectRepository repo) {
        this.repo = repo;
    }

    CommandResult createDataSubject(CreateDataSubjectRequest req) {
        if (req.externalId.isEmpty)
            return CommandResult(false, "", "External ID is required");

        DataSubject ds;
        ds.initEntity(req.tenantId, req.createdBy);

        ds.roleId = DataSubjectRoleId(req.roleId);
        ds.applicationGroupId = ApplicationGroupId(req.applicationGroupId);
        ds.externalId = req.externalId;
        ds.lifecycleStatus = DataLifecycleStatus.active;
        ds.createdAt = clockSeconds();

        repo.save(ds);
        return CommandResult(true, ds.id.value, "");
    }

    CommandResult updateDataSubject(UpdateDataSubjectRequest req) {
        auto ds = repo.findById(req.tenantId, DataSubjectId(req.id));
        if (ds.isNull)
            return CommandResult(false, "", "Data subject not found");

        if (req.lifecycleStatus.length > 0)
            ds.lifecycleStatus = parseLifecycleStatus(req.lifecycleStatus);
        if (req.roleId.length > 0)
            ds.roleId = DataSubjectRoleId(req.roleId);
        ds.updatedAt = clockSeconds();

        repo.update(ds);
        return CommandResult(true, ds.id.value, "");
    }

    CommandResult blockDataSubject(TenantId tenantId, DataSubjectId id) {
        auto ds = repo.findById(tenantId, id);
        if (ds.isNull)
            return CommandResult(false, "", "Data subject not found");

        ds.lifecycleStatus = DataLifecycleStatus.blocked;
        ds.blockedAt = clockSeconds();
        ds.updatedAt = clockSeconds();
        repo.update(ds);
        return CommandResult(true, id.value, "");
    }

    bool hasDataSubjectById(TenantId tenantId, DataSubjectId id) {
        return repo.existsById(tenantId, id);
    }

    DataSubject getDataSubject(TenantId tenantId, DataSubjectId id) {
        return repo.findById(tenantId, id);
    }

    DataSubject[] listDataSubjects(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataSubject[] listDataSubjects(TenantId tenantId, DataLifecycleStatus status) {
        return repo.findByLifecycleStatus(tenantId, status);
    }

    CommandResult deleteDataSubject(TenantId tenantId, DataSubjectId id) {
        auto subject = repo.findById(tenantId, id);
        if (subject.isNull)
            return CommandResult(false, "", "Data subject not found");

        repo.remove(subject);
        return CommandResult(true, subject.id.value, "");
    }
}
