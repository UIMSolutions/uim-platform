/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.data_subjects;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageDataSubjectsUseCase { // TODO: UIMUseCase {
    private DataSubjectRepository repo;

    this(DataSubjectRepository repo) {
        this.repo = repo;
    }

    CommandResult createDataSubject(CreateDataSubjectRequest r) {
        if (r.isNull) return CommandResult(false, "", "ID is required");
        if (r.firstName.length == 0 && r.lastName.length == 0)
            return CommandResult(false, "", "First name or last name is required");

        

        DataSubject ds;
        ds.id = r.id;
        ds.tenantId = r.tenantId;
        ds.subjectType = r.subjectType.length > 0 ? r.subjectType.to!DataSubjectType : DataSubjectType.privatePerson;
        ds.status = DataSubjectStatus.active;
        ds.firstName = r.firstName;
        ds.lastName = r.lastName;
        ds.email = r.email;
        ds.phoneNumber = r.phoneNumber;
        ds.dateOfBirth = r.dateOfBirth;
        ds.nationality = r.nationality;
        ds.organizationName = r.organizationName;
        ds.organizationId = r.organizationId;
        ds.externalId = r.externalId;
        ds.createdBy = r.createdBy;
        ds.createdAt = clockTime();

        repo.save(ds);
        return CommandResult(true, ds.id.value, "");
    }

    DataSubject getDataSubject(TenantId tenantId, DataSubjectId id) {
        return repo.findById(tenantId, id);
    }

    DataSubject[] listDataSubjects(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataSubject[] searchDataSubjectsByName(TenantId tenantId, string firstName, string lastName) {
        return repo.findByName(tenantId, firstName, lastName);
    }

    DataSubject findDataSubjectByEmail(TenantId tenantId, string email) {
        return repo.findByEmail(tenantId, email);
    }

    CommandResult updateDataSubject(UpdateDataSubjectRequest r) {
        auto existing = repo.findById(r.tenantId, r.subjectId);
        if (existing.isNull)
            return CommandResult(false, "", "Data subject not found");

        if (r.firstName.length > 0) existing.firstName = r.firstName;
        if (r.lastName.length > 0) existing.lastName = r.lastName;
        if (r.email.length > 0) existing.email = r.email;
        if (r.phoneNumber.length > 0) existing.phoneNumber = r.phoneNumber;
        if (r.organizationName.length > 0) existing.organizationName = r.organizationName;
        existing.updatedBy = r.updatedBy;
        existing.updatedAt = clockTime();

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult blockDataSubject(TenantId tenantId, DataSubjectId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Data subject not found");

        existing.status = DataSubjectStatus.blocked;
        existing.updatedAt = clockTime();
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult eraseDataSubject(TenantId tenantId, DataSubjectId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Data subject not found");

        existing.status = DataSubjectStatus.erased;
        existing.firstName = "***";
        existing.lastName = "***";
        existing.email = "***";
        existing.phoneNumber = "***";
        existing.dateOfBirth = "";
        existing.updatedAt = clockTime();
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDataSubject(TenantId tenantId, DataSubjectId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Data subject not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
