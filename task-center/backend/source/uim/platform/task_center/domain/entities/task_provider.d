/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A connected task provider system (S/4HANA, SuccessFactors, custom REST …).
module uim.platform.task_center.domain.entities.task_provider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskProvider {
  mixin TenantEntity!TaskProviderId;

  string name;
  string description;
  ProviderType providerType = ProviderType.custom;
  ProviderStatus status = ProviderStatus.inactive;
  AuthenticationType authType = AuthenticationType.none;

  string endpointUrl; /// task feed (GET → JSON array of tasks)
  string authEndpointUrl; /// OAuth2 token endpoint
  string clientId;
  string clientSecret; /// write-only, never serialized

  long lastSyncAt; /// std time of the last sync attempt, 0 = never
  string lastSyncError;

  bool canSync() const {
    return status != ProviderStatus.inactive && endpointUrl.length > 0;
  }

  void validate() const {
    requireText(name, "Provider name");
    if (endpointUrl.length > 0 && !isHttpUrl(endpointUrl))
      throw TaskCenterException.invalid("endpointUrl must be an http(s) URL");
    if (authEndpointUrl.length > 0 && !isHttpUrl(authEndpointUrl))
      throw TaskCenterException.invalid("authEndpointUrl must be an http(s) URL");
    if (authType == AuthenticationType.oauth2 && endpointUrl.length > 0 && (authEndpointUrl.length == 0 || clientId.length == 0))
      throw TaskCenterException.invalid("OAuth2 providers need authEndpointUrl and clientId");
    if (authType == AuthenticationType.basicAuth && endpointUrl.length > 0 && clientId.length == 0)
      throw TaskCenterException.invalid("Basic authentication needs clientId (user) and clientSecret (password)");
  }
}

///
unittest {
  TaskProvider p;
  p.name = "S/4HANA";
  p.validate();
  assert(!p.canSync);
  p.endpointUrl = "https://s4.example.com/tasks";
  p.status = ProviderStatus.active;
  assert(p.canSync);
  p.authType = AuthenticationType.oauth2;
  assert(failsWith(TaskCenterErrorKind.invalid, () { p.validate(); }));
}
