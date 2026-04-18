module uim.platform.data_retention.domain.ports.repositories.legal_entities;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface LegalEntityRepository { //: ITenantRepository!(LegalEntity, LegalEntityId) {
    bool existsById(LegalEntityId id);
    LegalEntity findById(LegalEntityId id);

    LegalEntity[] findAll(TenantId tenantId);
    LegalEntity[] findActive(TenantId tenantId);

    void save(LegalEntity a);
    void save(TenantId tenantId, LegalEntity a);
    void update(LegalEntity a);
    void update(TenantId tenantId, LegalEntity a);
}
