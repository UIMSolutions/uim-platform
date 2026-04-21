/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.purpose_records;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.purpose_record;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying purpose records.
interface PurposeRecordRepository : ITenantRepository!(PurposeRecord, PurposeRecordId) {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  PurposeRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

  size_t countByStatus(TenantId tenantId, PurposeRecordStatus status);
  PurposeRecord[] findByStatus(TenantId tenantId, PurposeRecordStatus status);
  void removeByStatus(TenantId tenantId, PurposeRecordStatus status);

  size_t countByBusinessContext(TenantId tenantId, BusinessContextId contextId);
  PurposeRecord[] findByBusinessContext(TenantId tenantId, BusinessContextId contextId);
  void removeByBusinessContext(TenantId tenantId, BusinessContextId contextId);

}
