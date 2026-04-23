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

    size_t countByDataSubject(DataSubjectId dataSubjectId);
    PersonalDataRecord[] findByDataSubject(DataSubjectId dataSubjectId);
    void removeByDataSubject(DataSubjectId dataSubjectId);

    size_t countByApplication(RegisteredApplicationId applicationId);
    PersonalDataRecord[] findByApplication(RegisteredApplicationId applicationId);
    void removeByApplication(RegisteredApplicationId applicationId);

    size_t countByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId applicationId);
    PersonalDataRecord[] findByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId applicationId);
    void removeByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId applicationId);
    
}
