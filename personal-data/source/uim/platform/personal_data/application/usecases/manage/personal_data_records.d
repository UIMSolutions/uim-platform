/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.personal_data_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManagePersonalDataRecordsUseCase { // TODO: UIMUseCase {
    private PersonalDataRecordRepository repo;

    this(PersonalDataRecordRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreatePersonalDataRecordRequest r) {
        if (r.isNull) return CommandResult(false, "", "ID is required");
        if (r.dataSubjectId.isEmpty) return CommandResult(false, "", "Data subject ID is required");

        

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
        return CommandResult(true, rec.id.value, "");
    }

    PersonalDataRecord getById(PersonalDataRecordId id) {
        return repo.findById(tenantId, id);
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

    CommandResult deletePersonalDataRecord(PersonalDataRecordId id) {
        auto record = repo.findById(tenantId, id);
        if (record.isNull)
            return CommandResult(false, "", "Personal data record not found");

        repo.remove(record);
        return CommandResult(true, record.id.value, "");
    }
}
