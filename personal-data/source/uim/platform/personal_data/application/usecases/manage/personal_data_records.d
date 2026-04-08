/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.personal_data_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManagePersonalDataRecordsUseCase : UIMUseCase {
    private PersonalDataRecordRepository repo;

    this(PersonalDataRecordRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreatePersonalDataRecordRequest r) {
        if (r.id.isEmpty) return CommandResult(false, "", "ID is required");
        if (r.dataSubjectid.isEmpty) return CommandResult(false, "", "Data subject ID is required");

        import std.conv : to;

        PersonalDataRecord rec;
        rec.id = r.id;
        rec.tenantId = r.tenantId;
        rec.dataSubjectId = r.dataSubjectId;
        rec.applicationId = r.applicationId;
        rec.dataCategoryId = r.dataCategoryId;
        rec.sensitivity = r.sensitivity.length > 0 ? r.sensitivity.to!DataSensitivity : DataSensitivity.standard;
        rec.fieldName = r.fieldName;
        rec.fieldValue = r.fieldValue;
        rec.purposeId = r.purposeId;
        rec.legalBasis = r.legalBasis;
        rec.sourceSystem = r.sourceSystem;
        rec.retentionRuleId = r.retentionRuleId;
        rec.createdBy = r.createdBy;
        rec.createdAt = clockTime();

        repo.save(rec);
        return CommandResult(true, rec.id, "");
    }

    PersonalDataRecord get_(PersonalDataRecordId id) {
        return repo.findById(id);
    }

    PersonalDataRecord[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    PersonalDataRecord[] listByDataSubject(DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(dataSubjectId);
    }

    PersonalDataRecord[] listByApplication(RegisteredApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    PersonalDataRecord[] listByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId appId) {
        return repo.findByDataSubjectAndApplication(dataSubjectId, appId);
    }

    CommandResult remove(PersonalDataRecordId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Personal data record not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
