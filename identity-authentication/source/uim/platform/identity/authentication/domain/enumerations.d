module uim.platform.identity.authentication.domain.enumerations;

import uim.platform.identity.authentication;

mixin(ShowModule!());

@safe:

/// Multi-factor authentication type.
enum MfaType {
  none,
  totp,
  sms,
  email,
}

/// User status in the identity directory.
enum UserStatus {
  active,
  inactive,
  locked,
  pendingVerification,
}
/// Risk level determined by risk-based authentication.
enum RiskLevel {
  low,
  medium,
  high,
  critical,
}
/// Token type.
enum TokenType {
  access,
  refresh,
  idToken,
  samlAssertion,
}
/// Provisioning job status.
enum JobStatus {
  pending,
  running,
  completed,
  failed,
}
/// Identity provider type for delegation.
enum IdpType {
  local,
  saml,
  oidc,
  ldap,
  corporate,
}
