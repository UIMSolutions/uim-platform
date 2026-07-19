/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.buckets;

// import uim.platform.object_store.domain.entities.bucket;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Port: outgoing - bucket persistence.
interface BucketRepository : ITenantRepository!(Bucket, BucketId) {

  bool existsByName(TenantId tenantId, string name);
  Bucket findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);
  
}
