module uim.platform.data_retention.domain.ports.repositories.legal_entities;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface ILegalEntityRepository : ITenantRepository!(LegalEntity, LegalEntityId) {

    LegalEntity[] findActive(TenantId tenantId);

}
