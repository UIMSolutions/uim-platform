/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.personal_data_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface PersonalDataRecordRepository {
    bool existsById(PersonalDataRecordId id);
    PersonalDataRecord findById(PersonalDataRecordId id);

    PersonalDataRecord[] findByTenant(TenantId tenantId);
    PersonalDataRecord[] findByDataSubject(DataSubjectId dataSubjectId);
    PersonalDataRecord[] findByApplication(RegisteredApplicationId applicationId);
    PersonalDataRecord[] findByDataSubjectAndApplication(DataSubjectId dataSubjectId, RegisteredApplicationId applicationId);
    void save(PersonalDataRecord entity);
    void update(PersonalDataRecord entity);
    void remove(PersonalDataRecordId id);
}
