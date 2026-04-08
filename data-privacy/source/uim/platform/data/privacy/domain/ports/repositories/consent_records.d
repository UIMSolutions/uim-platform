/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.consent_records;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.consent_record;

/// Port for persisting consent records.
interface ConsentRecordRepository {
  bool existsByTenant(TenantId tenantId);
  ConsentRecord[] findByTenant(TenantId tenantId);
 
  bool existsById(ConsentRecordId id, TenantId tenantId);
  ConsentRecord findById(ConsentRecordId id, TenantId tenantId);

  ConsentRecord[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  ConsentRecord[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);
  ConsentRecord[] findByStatus(TenantId tenantId, ConsentStatus status);
  ConsentRecord[] findActiveConsents(TenantId tenantId, DataSubjectId dataSubjectId);

  void save(ConsentRecord record);
  void update(ConsentRecord record);
  void remove(ConsentRecordId id, TenantId tenantId);
}
