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
class MemoryLegalGroundRepository : LegalGroundRepository {
  private LegalGround[] store;

  LegalGround[] findByTenant(TenantId tenantId) {
    LegalGround[] result;
    foreach (g; findAll)
      if (g.tenantId == tenantId)
        result ~= g;
    return result;
  }

  LegalGround* findById(LegalGroundId tenantId, id tenantId) {
    foreach (g; findAll)
      if (g.id == id && g.tenantId == tenantId)
        return &g;
    return null;
  }

  LegalGround[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    LegalGround[] result;
    foreach (g; findByTenant(tenantId))
      if (g.dataSubjectId == dataSubjectId)
        result ~= g;
    return result;
  }

  LegalGround[] findByBasis(TenantId tenantId, LegalBasis basis) {
    LegalGround[] result;
    foreach (g; findByTenant(tenantId))
      if (g.basis == basis)
        result ~= g;
    return result;
  }

  LegalGround[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    LegalGround[] result;
    foreach (g; findByTenant(tenantId))
      if (g.purpose == purpose)
        result ~= g;
    return result;
  }

  LegalGround[] findActive(TenantId tenantId, DataSubjectId dataSubjectId) {
    LegalGround[] result;
    foreach (g; findByTenant(tenantId))
      if (g.dataSubjectId == dataSubjectId && g.isActive)
        result ~= g;
    return result;
  }

  void save(LegalGround ground) {
    store ~= ground;
  }

  void update(LegalGround ground) {
    foreach (g; findAll)
      if (g.id == ground.id && g.tenantId == ground.tenantId) {
        g = ground;
        return;
      }
  }

  void remove(LegalGroundId tenantId, id tenantId) {
    LegalGround[] kept;
    foreach (g; findAll)
      if (!(g.id == id && g.tenantId == tenantId))
        kept ~= g;
    store = kept;
  }
}
