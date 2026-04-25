module uim.platform.data_retention.infrastructure.persistence.memory.legal_grounds;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryLegalGroundRepository : TenantRepository!(LegalGround, LegalGroundId), LegalGroundRepository {
    
    
    LegalGround[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    LegalGround[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    LegalGround[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByTenant(tenantId).filter!(a => a.businessPurposeId == purposeId).array;
    }
    LegalGround[] findByType(TenantId tenantId, LegalGroundType type) {
        return findByTenant(tenantId).filter!(a => a.type == type).array;
    }


}
