module uim.platform.data_retention.domain.ports.repositories.legal_grounds;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface ILegalGroundRepository : ITenantRepository!(LegalGround, LegalGroundId) {

    LegalGround[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId);
    LegalGround[] findByType(TenantId tenantId, LegalGroundType type);

}
