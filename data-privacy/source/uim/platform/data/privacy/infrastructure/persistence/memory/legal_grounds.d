/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.legal_grounds;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.legal_ground;
// import uim.platform.data.privacy.domain.ports.repositories.legal_grounds;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryLegalGroundRepository : TenantRepository!(LegalGround, LegalGroundId), LegalGroundRepository {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return findByDataSubject(tenantId, dataSubjectId).length;
  }

  LegalGround[] filterByDataSubject(LegalGround[] grounds, DataSubjectId dataSubjectId) {
    return grounds.filter!(g => g.dataSubjectId == dataSubjectId).array;
  } 

  LegalGround[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return filterByDataSubject(findByTenant(tenantId), dataSubjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    findByDataSubject(tenantId, dataSubjectId).each!(entity => remove(entity.id));
  }

  size_t countByBasis(TenantId tenantId, LegalBasis basis) {
    return findByBasis(tenantId, basis).length;
  }

  LegalGround[] filterByBasis(LegalGround[] grounds, LegalBasis basis) {
    return grounds.filter!(g => g.basis == basis).array;
  }

  LegalGround[] findByBasis(TenantId tenantId, LegalBasis basis) {
    return filterByBasis(findByTenant(tenantId), basis);
  }

  void removeByBasis(TenantId tenantId, LegalBasis basis) {
    findByBasis(tenantId, basis).each!(entity => remove(entity.id));
  }

  size_t countByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    return findByPurpose(tenantId, purpose).length;
  }

  LegalGround[] filterByPurpose(LegalGround[] grounds, ProcessingPurpose purpose) {
    return grounds.filter!(g => g.purpose == purpose).array;
  }

  LegalGround[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    return filterByPurpose(findByTenant(tenantId), purpose);
  }

  void removeByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    findByPurpose(tenantId, purpose).each!(entity => remove(entity.id));
  }

  size_t countActive(TenantId tenantId, DataSubjectId dataSubjectId) {
    return findActive(tenantId, dataSubjectId).length;
  }

  LegalGround[] filterActive(LegalGround[] grounds, DataSubjectId dataSubjectId) {
    return grounds.filter!(g => g.dataSubjectId == dataSubjectId && g.isActive).array;
  } 

  LegalGround[] findActive(TenantId tenantId, DataSubjectId dataSubjectId) {
    return filterActive(findByTenant(tenantId), dataSubjectId);
  }

  void removeActive(TenantId tenantId, DataSubjectId dataSubjectId) {
    findActive(tenantId, dataSubjectId).each!(entity => remove(entity.id));
  }
  
}
