/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.enumerations.access;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Effect of an access policy statement. An explicit deny always wins.
enum PolicyEffect {
  allow,
  deny,
}

/// Data plane operations governed by access policies and binding permissions.
enum PolicyAction {
  read, /// download content, read metadata (GetObject / HeadObject)
  write, /// upload or overwrite content (PutObject / CopyObject target)
  delete_, /// delete objects or versions (DeleteObject)
  list, /// list keys (ListObjects)
  all, /// every action
}

/// What a service binding (access key) may do.
enum BindingPermission {
  readOnly, /// read, list
  readWrite, /// read, list, write, delete
  admin, /// every action
}

/// Lifecycle of a service binding.
enum BindingStatus {
  active,
  revoked, /// final — create a new binding instead
  expired, /// expiresAt has passed
}

/// The actions a binding permission grants.
bool permits(BindingPermission permission, PolicyAction action) pure nothrow {
  final switch (permission) {
  case BindingPermission.admin:
    return true;
  case BindingPermission.readWrite:
    return action != PolicyAction.all;
  case BindingPermission.readOnly:
    return action == PolicyAction.read || action == PolicyAction.list;
  }
}

///
unittest {
  assert(permits(BindingPermission.readOnly, PolicyAction.list));
  assert(!permits(BindingPermission.readOnly, PolicyAction.write));
  assert(permits(BindingPermission.readWrite, PolicyAction.delete_));
  assert(enumText(PolicyAction.delete_) == "delete");
  assert(parseEnum!PolicyAction("DELETE", PolicyAction.read) == PolicyAction.delete_);
}
