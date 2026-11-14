/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.service_binding;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// A connection from a dev space to a backend system or BTP service
/// (used by run configurations of the dev space's projects).
struct ServiceBinding {
  mixin TenantEntity!ServiceBindingId;

  DevSpaceId devSpaceId;
  string devSpaceName;
  string name; /// unique per dev space
  string description;
  ServiceProviderType providerType = ServiceProviderType.sapBtp;
  BindingStatus status = BindingStatus.disconnected;
  string statusMessage;

  string systemAlias; /// BTP destination name (alternative to serviceUrl)
  string serviceUrl;
  string servicePath; /// e.g. /sap/opu/odata4/sap/api_travel/srvd_a2x/sap/travel/0001/
  BindingAuthType authType = BindingAuthType.noAuthentication;
  string user;
  string credentials; /// password / client secret — masked by the adapters
  long connectedAt;
}
