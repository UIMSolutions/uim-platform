/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.purpose_records;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface ManagePurposeRecordsUseCase { 

  UsecaseResult createRecord(CreatePurposeRecordRequest req);
  PurposeRecord getRecord(TenantId tenantId, PurposeRecordId id);
  PurposeRecord[] listRecords(TenantId tenantId);
  PurposeRecord[] listRecords(TenantId tenantId, DataSubjectId subjectId);
  PurposeRecord[] listRecords(TenantId tenantId, PurposeRecordStatus status);
  UsecaseResult deactivateRecord(DeactivatePurposeRecordRequest req);
  UsecaseResult deleteRecord(TenantId tenantId, PurposeRecordId recordId);

}
