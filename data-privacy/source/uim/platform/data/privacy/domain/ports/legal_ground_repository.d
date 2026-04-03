module uim.platform.xyz.domain.ports.legal_ground_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.legal_ground;

/// Port for persisting legal grounds for data processing.
interface LegalGroundRepository
{
    LegalGround[] findByTenant(TenantId tenantId);
    LegalGround* findById(LegalGroundId id, TenantId tenantId);
    LegalGround[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    LegalGround[] findByBasis(TenantId tenantId, LegalBasis basis);
    LegalGround[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);
    LegalGround[] findActive(TenantId tenantId, DataSubjectId dataSubjectId);
    void save(LegalGround ground);
    void update(LegalGround ground);
    void remove(LegalGroundId id, TenantId tenantId);
}
