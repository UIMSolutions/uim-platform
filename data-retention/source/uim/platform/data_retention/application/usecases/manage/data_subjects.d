/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.application.usecases.manage.data_subjects;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDataSubjectsUseCase {
    private IDataSubjectRepository repo;

    this(IDataSubjectRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createDataSubject(CreateDataSubjectRequest req) {
        if (req.externalId.isEmpty)
            return UsecaseResult(false, "", "External ID is required");

        auto ds = DataSubject(req.tenantId, DataSubjectId(createId), req.createdBy);
        ds.roleId = DataSubjectRoleId(req.roleId);
        ds.groupId = ApplicationGroupId(req.applicationGroupId);
        ds.externalId = req.externalId;
        ds.lifecycleStatus = DataLifecycleStatus.active;
        ds.createdAt = clockSeconds();

        repo.save(ds);
        return UsecaseResult(true, ds.id.value, "");
    }

    UsecaseResult updateDataSubject(UpdateDataSubjectRequest req) {
        auto ds = repo.findById(req.tenantId, req.subjectId);
        if (ds.isNull)
            return UsecaseResult(false, "", "Data subject not found");

        if (req.lifecycleStatus.length > 0)
            ds.lifecycleStatus = req.lifecycleStatus.toDataLifecycleStatus;

        if (req.roleId.length > 0)
            ds.roleId = DataSubjectRoleId(req.roleId);
        
        ds.updatedAt = currentTimestamp;

        repo.update(ds);
        return UsecaseResult(true, ds.id.value, "");
    }

    UsecaseResult blockDataSubject(TenantId tenantId, DataSubjectId id) {
        auto ds = repo.findById(tenantId, id);
        if (ds.isNull)
            return UsecaseResult(false, "", "Data subject not found");

        ds.lifecycleStatus = DataLifecycleStatus.blocked;
        ds.blockedAt = currentTimestamp();
        ds.updatedAt = currentTimestamp();

        repo.update(ds);
        return UsecaseResult(true, id.value, "");
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

    UsecaseResult deleteDataSubject(TenantId tenantId, DataSubjectId id) {
        auto subject = repo.findById(tenantId, id);
        if (subject.isNull)
            return UsecaseResult(false, "", "Data subject not found");

        repo.remove(subject);
        return UsecaseResult(true, subject.id.value, "");
    }
}
