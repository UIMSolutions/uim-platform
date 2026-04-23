/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.consent_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface ConsentRecordRepository : ITenantRepository!(ConsentRecord, ConsentRecordId) {

    size_t countByDataSubject(DataSubjectId dataSubjectId);
    ConsentRecord[] findByDataSubject(DataSubjectId dataSubjectId);
    void removeByDataSubject(DataSubjectId dataSubjectId);

    size_t countByPurpose(ProcessingPurposeId purposeId);
    ConsentRecord[] findByPurpose(ProcessingPurposeId purposeId);
    void removeByPurpose(ProcessingPurposeId purposeId);

    ConsentRecord findByDataSubjectAndPurpose(DataSubjectId dataSubjectId, ProcessingPurposeId purposeId);
    
}
