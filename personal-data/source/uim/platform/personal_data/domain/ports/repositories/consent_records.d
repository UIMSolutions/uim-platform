/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.consent_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface ConsentRecordRepository {
    ConsentRecord findById(ConsentRecordId id);
    ConsentRecord[] findByTenant(TenantId tenantId);
    ConsentRecord[] findByDataSubject(DataSubjectId dataSubjectId);
    ConsentRecord[] findByPurpose(ProcessingPurposeId purposeId);
    ConsentRecord findByDataSubjectAndPurpose(DataSubjectId dataSubjectId, ProcessingPurposeId purposeId);
    void save(ConsentRecord entity);
    void update(ConsentRecord entity);
    void remove(ConsentRecordId id);
}
