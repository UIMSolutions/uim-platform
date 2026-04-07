/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.business_contexts;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.business_context;

/// Port for persisting and querying business contexts.
interface BusinessContextRepository {
  BusinessContext[] findByTenant(TenantId tenantId);
  BusinessContext* findById(BusinessContextId id, TenantId tenantId);
  BusinessContext[] findByStatus(TenantId tenantId, BusinessContextStatus status);
  BusinessContext[] findByControllerGroup(TenantId tenantId, DataControllerGroupId groupId);
  void save(BusinessContext context);
  void update(BusinessContext context);
  void remove(BusinessContextId id, TenantId tenantId);
}
