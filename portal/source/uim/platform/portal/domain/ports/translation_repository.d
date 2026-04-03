module uim.platform.xyz.domain.ports.translation_repository;

import domain.entities.translation;
import domain.types;

/// Port: outgoing — translation persistence.
interface TranslationRepository
{
    Translation findById(TranslationId id);
    Translation[] findByResource(string resourceType, string resourceId, string language = "");
    Translation[] findByLanguage(TenantId tenantId, string language, uint offset = 0, uint limit = 100);
    void save(Translation translation);
    void update(Translation translation);
    void remove(TranslationId id);
    void removeByResource(string resourceType, string resourceId);
}
