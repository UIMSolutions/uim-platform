/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.consent_purposes;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.consent_purpose;

/// Port for persisting and querying consent purpose configurations.
interface ConsentPurposeRepository : ITenantRepository!(ConsentPurpose, ConsentPurposeId) {
  
  size_t countByController(TenantId tenantId, DataControllerId controllerId);
  ConsentPurpose[] findByController(TenantId tenantId, DataControllerId controllerId);
  void removeByController(TenantId tenantId, DataControllerId controllerId);

  size_t countByStatus(TenantId tenantId, ConsentPurposeStatus status);
  ConsentPurpose[] findByStatus(TenantId tenantId, ConsentPurposeStatus status);
  void removeByStatus(TenantId tenantId, ConsentPurposeStatus status);
  
}
