module uim.platform.object_store.domain.ports.repositories.cors_rule;

import uim.platform.object_store.domain.entities.cors_rule;
import uim.platform.object_store.domain.types;

/// Port: outgoing - CORS rule persistence.
interface CorsRuleRepository
{
    CorsRule findById(CorsRuleId id);
    CorsRule[] findByBucket(BucketId bucketId);
    void save(CorsRule rule);
    void update(CorsRule rule);
    void remove(CorsRuleId id);
}
