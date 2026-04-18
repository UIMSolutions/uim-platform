module uim.platform.data_retention.domain.ports.repositories.legal_grounds;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface LegalGroundRepository { //: ITenantRepository!(LegalGround, LegalGroundId) {
    bool existsById(LegalGroundId id);
    LegalGround findById(LegalGroundId id);

    LegalGround[] findAll(TenantId tenantId);
    LegalGround[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId);
    LegalGround[] findByType(TenantId tenantId, LegalGroundType type);

    void save(LegalGround a);
    void save(TenantId tenantId, LegalGround a);
    void update(LegalGround a);
    void update(TenantId tenantId, LegalGround a);
}
