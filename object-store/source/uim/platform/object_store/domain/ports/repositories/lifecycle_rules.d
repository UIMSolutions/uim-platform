/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.lifecycle_rules;

// import uim.platform.object_store.domain.entities.lifecycle_rule;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Port: outgoing - lifecycle rule persistence.
interface LifecycleRuleRepository {
  bool existsById(LifecycleRuleId id);
  LifecycleRule findById(LifecycleRuleId id);

  LifecycleRule[] findByBucket(BucketId bucketId);
  
  void save(LifecycleRule rule);
  void update(LifecycleRule rule);
  void remove(LifecycleRuleId id);
}
