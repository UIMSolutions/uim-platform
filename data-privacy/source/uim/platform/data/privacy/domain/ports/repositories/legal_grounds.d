/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.legal_grounds;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.legal_ground;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting legal grounds for data processing.
interface LegalGroundRepository : ITenantRepository!(LegalGround, LegalGroundId) {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  LegalGround[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

  size_t countByBasis(TenantId tenantId, LegalBasis basis);
  LegalGround[] findByBasis(TenantId tenantId, LegalBasis basis);
  void removeByBasis(TenantId tenantId, LegalBasis basis);

  size_t countByPurpose(TenantId tenantId, ProcessingPurpose purpose);
  LegalGround[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);
  void removeByPurpose(TenantId tenantId, ProcessingPurpose purpose);

  size_t countActive(TenantId tenantId, DataSubjectId dataSubjectId);
  LegalGround[] findActive(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeActive(TenantId tenantId, DataSubjectId dataSubjectId);

}
