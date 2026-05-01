/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.cors_rules;

// import uim.platform.object_store.domain.entities.cors_rule;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Port: outgoing - CORS rule persistence.
interface CorsRuleRepository {
  bool existsById(CorsRuleId id);
  CorsRule findById(CorsRuleId id);

  CorsRule[] findByBucket(BucketId bucketId);
  
  void save(CorsRule rule);
  void update(CorsRule rule);
  void remove(CorsRuleId id);
}
