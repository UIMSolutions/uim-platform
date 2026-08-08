/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.usecases.consent_records;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface IManageConsentRecordsUseCase { 

    CommandResult createConsentRecord(CreateConsentRecordRequest r);
    bool hasConsentRecord(TenantId tenantId, ConsentRecordId id);
    ConsentRecord getConsentRecord(TenantId tenantId, ConsentRecordId id);
    ConsentRecord[] listConsentRecords(TenantId tenantId);
    ConsentRecord[] listConsentRecords(TenantId tenantId, DataSubjectId dataSubjectId);
    CommandResult withdrawConsentRecord(WithdrawConsentRequest r);
    CommandResult deleteConsentRecord(TenantId tenantId, ConsentRecordId id);
    
}
