/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.dtos.requests;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Generic request envelopes. A *Spec holds the user-settable fields of an
/// aggregate; its field names equal the entity's so that adapters can derive a
/// spec from an existing entity (PATCH = decode(patch, spec of current)).

/// Create an aggregate below a parent (bucket).
struct CreateRequest(TParentId, TSpec) {
  TenantId tenantId;
  UserId actor;
  TParentId parentId;
  TSpec spec;
}

/// Create a root aggregate (bucket).
struct CreateRootRequest(TSpec) {
  TenantId tenantId;
  UserId actor;
  TSpec spec;
}

/// Replace the mutable fields of an aggregate. Immutable fields are ignored.
struct UpdateRequest(TId, TSpec) {
  TenantId tenantId;
  UserId actor;
  TId id;
  TSpec spec;
}

/// Write the content of an object (data plane). Creates the object or a new version.
struct PutObjectRequest {
  TenantId tenantId;
  UserId actor;
  BucketId bucketId;
  string key;
  const(ubyte)[] data;
  string contentType; /// "" = keep / application/octet-stream
  MetadataEntry[] metadata;
  bool replaceMetadata; /// false keeps the metadata of an existing object
}

/// Evaluate the access policies of a bucket.
struct EvaluateAccessRequest {
  TenantId tenantId;
  BucketId bucketId;
  string principal;
  PolicyAction action;
  string key;
}

/// Check a browser (CORS preflight) request against the CORS rules of a bucket.
struct CheckCorsRequest {
  TenantId tenantId;
  BucketId bucketId;
  string origin;
  CorsMethod method;
  string[] requestHeaders;
}
