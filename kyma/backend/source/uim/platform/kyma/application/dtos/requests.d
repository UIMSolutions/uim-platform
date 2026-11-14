/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.requests;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Generic request envelopes. A *Spec holds the user-settable fields of an
/// aggregate; its field names equal the entity's so that adapters can derive a
/// spec from an existing entity (PATCH = decode(patch, spec of current)).

/// Create an aggregate below a parent (environment, namespace or service instance).
struct CreateRequest(TParentId, TSpec) {
  TenantId tenantId;
  UserId actor;
  TParentId parentId;
  TSpec spec;
}

/// Replace the mutable fields of an aggregate. Immutable fields (name, parent) are ignored.
struct UpdateRequest(TId, TSpec) {
  TenantId tenantId;
  UserId actor;
  TId id;
  TSpec spec;
}
