/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.purpose_records;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface ManagePurposeRecordsUseCase { 

  CommandResult createRecord(CreatePurposeRecordRequest req);
  PurposeRecord getRecord(TenantId tenantId, PurposeRecordId id);
  PurposeRecord[] listRecords(TenantId tenantId);
  PurposeRecord[] listRecords(TenantId tenantId, DataSubjectId subjectId);
  PurposeRecord[] listRecords(TenantId tenantId, PurposeRecordStatus status);
  CommandResult deactivateRecord(DeactivatePurposeRecordRequest req);
  CommandResult deleteRecord(TenantId tenantId, PurposeRecordId recordId);

}
