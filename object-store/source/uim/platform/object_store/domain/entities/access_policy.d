/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.access_policy;

// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class AccessPolicy {
  mixin TenantEntity!(AccessPolicyId);

  BucketId bucketId;
  string name;
  PolicyEffect effect = PolicyEffect.allow;
  string principal; // user/group/service identifier, "*" for all
  string actions; // JSON array, e.g. '["GetObject","PutObject"]'
  string resources; // JSON array of key patterns, e.g. '["images/*"]'
  
  Json toJson() const {
    auto j = entityToJson
      .set("bucketId", bucketId.value)
      .set("name", name)
      .set("effect", effect.toString())
      .set("principal", principal)
      .set("actions", actions)
      .set("resources", resources);

    return j;
  }
}
