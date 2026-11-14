/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations.bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Kind of system a service binding points to.
enum ServiceProviderType {
  sapBtp, /// BTP service / destination
  sapS4Hana,
  sapSuccessFactors,
  externalOData,
  externalRest,
}

/// True for providers whose services are OData (need a service path).
bool isODataProvider(ServiceProviderType t) pure nothrow {
  with (ServiceProviderType)
    return t == sapS4Hana || t == sapSuccessFactors || t == externalOData;
}

/// Authentication used by a service binding.
enum BindingAuthType {
  noAuthentication,
  basicAuthentication,
  oauth2ClientCredentials,
  principalPropagation,
}

/// True if the auth type needs stored credentials.
bool needsCredentials(BindingAuthType a) pure nothrow {
  return a == BindingAuthType.basicAuthentication || a == BindingAuthType.oauth2ClientCredentials;
}

/// Connection status of a service binding.
///
///   disconnected → connecting → connected | error ;  connected | error → disconnected
enum BindingStatus {
  disconnected,
  connecting,
  connected,
  error,
}

///
unittest {
  assert(ServiceProviderType.externalOData.isODataProvider && !ServiceProviderType.externalRest.isODataProvider);
  assert(BindingAuthType.basicAuthentication.needsCredentials && !BindingAuthType.principalPropagation.needsCredentials);
}
