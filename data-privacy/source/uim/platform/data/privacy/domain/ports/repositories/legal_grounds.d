/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.legal_grounds;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.legal_ground;

/// Port for persisting legal grounds for data processing.
interface LegalGroundRepository {
  bool existsTenant(TenantId tenantId);
  LegalGround[] findByTenant(TenantId tenantId);
 
  bool existsId(LegalGroundId id, TenantId tenantId);
  LegalGround findById(LegalGroundId id, TenantId tenantId);

  LegalGround[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  LegalGround[] findByBasis(TenantId tenantId, LegalBasis basis);
  LegalGround[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);
  LegalGround[] findActive(TenantId tenantId, DataSubjectId dataSubjectId);

  void save(LegalGround ground);
  void update(LegalGround ground);
  void remove(LegalGroundId id, TenantId tenantId);
}
