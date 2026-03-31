module uim.platform.object_store.domain.ports.repositories.lifecycle_rule_repository;

import domain.entities.lifecycle_rule;
import domain.types;

/// Port: outgoing - lifecycle rule persistence.
interface LifecycleRuleRepository
{
    LifecycleRule findById(LifecycleRuleId id);
    LifecycleRule[] findByBucket(BucketId bucketId);
    void save(LifecycleRule rule);
    void update(LifecycleRule rule);
    void remove(LifecycleRuleId id);
}
