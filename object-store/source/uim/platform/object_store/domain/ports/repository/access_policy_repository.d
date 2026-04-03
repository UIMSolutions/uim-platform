/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.access_policy;

import uim.platform.object_store.domain.entities.access_policy;
import uim.platform.object_store.domain.types;

/// Port: outgoing - access policy persistence.
interface AccessPolicyRepository
{
  AccessPolicy findById(AccessPolicyId id);
  AccessPolicy[] findByBucket(BucketId bucketId);
  AccessPolicy[] findByTenant(TenantId tenantId);
  void save(AccessPolicy policy);
  void update(AccessPolicy policy);
  void remove(AccessPolicyId id);
}
