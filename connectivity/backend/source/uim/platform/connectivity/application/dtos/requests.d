/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.dtos.requests;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Generic request envelopes. A *Spec holds the user-settable fields of an
/// aggregate; its field names equal the entity's so that adapters can derive a
/// spec from an existing entity (PATCH = decode(patch, spec of current)).

/// Create an aggregate below a parent (Cloud Connector).
struct CreateRequest(TParentId, TSpec) {
  TenantId tenantId;
  UserId actor;
  TParentId parentId;
  TSpec spec;
}

/// Create a root aggregate (destination, connector, certificate, log entry).
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

/// Would the Cloud Connector let a request to `url` through?
/// `connector` is a connector id or name; the URL scheme selects the protocol
/// (https://erp.virtual:443/sap/opu, rfc://erp.virtual:3300, ldap://dir:389).
struct AccessCheckRequest {
  TenantId tenantId;
  UserId actor;
  string connector;
  string url;
}
