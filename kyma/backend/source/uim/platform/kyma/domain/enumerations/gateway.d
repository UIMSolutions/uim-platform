/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.enumerations.gateway;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Access strategy of an API rule entry (APIRule v2).
enum AccessStrategy {
  noAuth,
  jwt,
  oauth2Introspection,
  extAuth,
}

/// Status of an API rule.
enum ApiRuleStatus {
  notReady,
  ok,
  error,
}

/// HTTP methods allowed by an API rule entry.
enum ApiHttpMethod : string {
  get_ = "GET",
  post_ = "POST",
  put_ = "PUT",
  patch_ = "PATCH",
  delete_ = "DELETE",
  head_ = "HEAD",
  options_ = "OPTIONS",
}

///
unittest {
  assert(parseEnum!ApiHttpMethod("get", ApiHttpMethod.post_) == ApiHttpMethod.get_);
  assert(enumText(ApiHttpMethod.delete_) == "DELETE");
  assert(parseEnum!AccessStrategy("JWT", AccessStrategy.noAuth) == AccessStrategy.jwt);
}
