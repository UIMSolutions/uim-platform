/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.purpose_records;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.purpose_record;

/// Port for persisting and querying purpose records.
interface PurposeRecordRepository {
  bool existsByTenant(TenantId tenantId);
  PurposeRecord[] findByTenant(TenantId tenantId);
 
  bool existsById(PurposeRecordId id, TenantId tenantId);
  PurposeRecord findById(PurposeRecordId id, TenantId tenantId);

  PurposeRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  PurposeRecord[] findByStatus(TenantId tenantId, PurposeRecordStatus status);
  PurposeRecord[] findByBusinessContext(TenantId tenantId, BusinessContextId contextId);

  void save(PurposeRecord record);
  void update(PurposeRecord record);
  void remove(PurposeRecordId id, TenantId tenantId);
}
