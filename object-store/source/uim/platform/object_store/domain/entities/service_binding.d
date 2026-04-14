/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.service_binding;

// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class ServiceBinding {
  ServiceBindingId id;
  TenantId tenantId;
  string name;
  BucketId bucketId;
  string accessKeyId;
  string secretAccessKeyHash; // stored hashed, never returned in plain text
  BindingPermission permission = BindingPermission.readOnly;
  BindingStatus status = BindingStatus.active;
  long expiresAt; // 0 = no expiry
  UserId createdBy;
  long createdAt;
}
