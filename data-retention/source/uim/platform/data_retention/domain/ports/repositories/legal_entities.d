module uim.platform.data_retention.domain.ports.repositories.legal_entities;
import uim.platform.data_retention;
mixin(ShowModule!());

@safe:

interface LegalEntityRepository : ITenantRepository!(LegalEntity, LegalEntityId) {

    LegalEntity[] findActive(TenantId tenantId);

}
