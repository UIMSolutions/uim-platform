/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.consent_purposes;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.consent_purpose;

/// Port for persisting and querying consent purpose configurations.
interface ConsentPurposeRepository {
  ConsentPurpose[] findByTenant(TenantId tenantId);
  ConsentPurpose* findById(ConsentPurposeId id, TenantId tenantId);
  ConsentPurpose[] findByController(TenantId tenantId, DataControllerId controllerId);
  ConsentPurpose[] findByStatus(TenantId tenantId, ConsentPurposeStatus status);
  void save(ConsentPurpose purpose);
  void update(ConsentPurpose purpose);
  void remove(ConsentPurposeId id, TenantId tenantId);
}
