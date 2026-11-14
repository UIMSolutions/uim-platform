/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.enumerations.provider;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// System a task provider connects to.
enum ProviderType : string {
  s4hana = "s4hana",
  successFactors = "successFactors",
  ariba = "ariba",
  fieldglass = "fieldglass",
  concur = "concur",
  sapBuild = "sapBuild",
  custom = "custom"
}

/// active / inactive are set by administrators; syncing and error by the sync.
enum ProviderStatus : string {
  active = "active",
  inactive = "inactive",
  syncing = "syncing",
  error = "error"
}

/// How the task center authenticates against the provider endpoint.
enum AuthenticationType : string {
  none = "none",
  oauth2 = "oauth2", /// client credentials grant (authEndpointUrl, clientId, clientSecret)
  basicAuth = "basicAuth", /// clientId:clientSecret
  apiKey = "apiKey", /// X-API-Key: clientSecret
  certificate = "certificate", /// mTLS, configured on the destination / runtime
  saml = "saml" /// SAML bearer assertion, configured on the destination
}
