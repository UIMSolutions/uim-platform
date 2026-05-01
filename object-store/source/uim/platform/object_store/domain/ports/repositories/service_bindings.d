/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.service_bindings;

// import uim.platform.object_store.domain.entities.service_binding;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Port: outgoing - service binding persistence.
interface ServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {

  size_t countByBucket(BucketId bucketId);
  ServiceBinding[] findByBucket(BucketId bucketId);
  void removeByBucket(BucketId bucketId);

}
