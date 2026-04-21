module uim.platform.service.domain.enumerations;

import uim.platform.service;

mixin(ShowModule!());

@safe:
/// SSO protocol.
enum SsoProtocol {
  saml,
  oidc,
}

/// Authentication method supported by the platform.
enum AuthMethod {
  form,
  spnego,
  social,
  certificate,
  saml,
  oidc,
  apiKey,
}