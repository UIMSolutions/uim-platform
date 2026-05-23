/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.personal_data_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface PersonalDataRecordRepository : ITenantRepository!(PersonalDataRecord, PersonalDataRecordId) {

    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    PersonalDataRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

    size_t countByApplication(TenantId tenantId, RegisteredApplicationId applicationId);
    PersonalDataRecord[] findByApplication(TenantId tenantId, RegisteredApplicationId applicationId);
    void removeByApplication(TenantId tenantId, RegisteredApplicationId applicationId);

    size_t countByDataSubjectAndApplication(TenantId tenantId, DataSubjectId dataSubjectId, RegisteredApplicationId applicationId);
    PersonalDataRecord[] findByDataSubjectAndApplication(TenantId tenantId, DataSubjectId dataSubjectId, RegisteredApplicationId applicationId);
    void removeByDataSubjectAndApplication(TenantId tenantId, DataSubjectId dataSubjectId, RegisteredApplicationId applicationId);
    
}
