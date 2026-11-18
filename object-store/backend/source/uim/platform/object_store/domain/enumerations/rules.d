/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.enumerations.rules;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Whether a lifecycle rule is applied.
enum RuleStatus {
  enabled,
  disabled,
}

/// HTTP methods a CORS rule can allow.
enum CorsMethod {
  get,
  put,
  post,
  delete_,
  head,
}

/// What a lifecycle run does to an object or version.
enum LifecycleStepKind {
  expire, /// delete the object (delete marker in versioned buckets)
  transition, /// move to a colder storage class
  purgeVersion, /// permanently delete a noncurrent version
}
