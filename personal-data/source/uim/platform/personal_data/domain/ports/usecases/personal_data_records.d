/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.usecases.personal_data_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface IManagePersonalDataRecordsUseCase { 

    UsecaseResult createPersonalDataRecord(CreatePersonalDataRecordRequest r);
    PersonalDataRecord getPersonalDataRecord(TenantId tenantId, PersonalDataRecordId id);
    PersonalDataRecord[] listPersonalDataRecords(TenantId tenantId);
    PersonalDataRecord[] listPersonalDataRecords(TenantId tenantId, DataSubjectId dataSubjectId);
    PersonalDataRecord[] listPersonalDataRecords(TenantId tenantId, RegisteredApplicationId applicationId);
    PersonalDataRecord[] listPersonalDataRecords(TenantId tenantId, DataSubjectId dataSubjectId, RegisteredApplicationId appId);
    UsecaseResult deletePersonalDataRecord(TenantId tenantId, PersonalDataRecordId id);

}
