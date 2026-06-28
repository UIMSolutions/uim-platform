/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.personal_data_records;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

class ManagePersonalDataRecordsUseCase { // TODO: UIMUseCase {
    private PersonalDataRecordRepository repo;

    this(PersonalDataRecordRepository repo) {
        this.repo = repo;
    }

    CommandResult createPersonalDataRecord(CreatePersonalDataRecordRequest r) {
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

    PersonalDataRecord getPersonalDataRecord(TenantId tenantId, PersonalDataRecordId id) {
        return repo.find(tenantId, id);
    }

    PersonalDataRecord[] listPersonalDataRecords(TenantId tenantId) {
        return repo.find(tenantId);
    }

    PersonalDataRecord[] listPersonalDataRecords(TenantId tenantId, DataSubjectId dataSubjectId) {
        return repo.findByDataSubject(tenantId, dataSubjectId);
    }

    PersonalDataRecord[] listPersonalDataRecords(TenantId tenantId, RegisteredApplicationId applicationId) {
        return repo.findByApplication(tenantId, applicationId);
    }

    PersonalDataRecord[] listPersonalDataRecords(TenantId tenantId, DataSubjectId dataSubjectId, RegisteredApplicationId appId) {
        return repo.findByDataSubjectAndApplication(tenantId, dataSubjectId, appId);
    }

    CommandResult deletePersonalDataRecord(TenantId tenantId, PersonalDataRecordId id) {
        auto record = repo.find(tenantId, id);
        if (record.isNull)
            return CommandResult(false, "", "Personal data record not found");

        repo.remove(record);
        return CommandResult(true, record.id.value, "");
    }
}
