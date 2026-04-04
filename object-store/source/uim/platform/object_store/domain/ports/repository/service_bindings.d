/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.service_binding;

import uim.platform.object_store.domain.entities.service_binding;
import uim.platform.object_store.domain.types;

/// Port: outgoing - service binding persistence.
interface ServiceBindingRepository {
  ServiceBinding findById(ServiceBindingId id);
  ServiceBinding[] findByBucket(BucketId bucketId);
  ServiceBinding[] findByTenant(TenantId tenantId);
  void save(ServiceBinding binding);
  void update(ServiceBinding binding);
  void remove(ServiceBindingId id);
}
