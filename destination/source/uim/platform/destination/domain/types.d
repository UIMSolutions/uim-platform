module uim.platform.destination.domain.types;

/// Unique identifier type aliases for type safety.
alias DestinationId = string;
alias CertificateId = string;
alias FragmentId = string;
alias TenantId = string;
alias SubaccountId = string;
alias ServiceInstanceId = string;

/// Type of destination connection.
enum DestinationType
{
  http,
  rfc,
  mail,
  ldap,
}

/// Authentication method for the destination.
enum AuthenticationType
{
  noAuthentication,
  basicAuthentication,
  oauth2ClientCredentials,
  oauth2SAMLBearerAssertion,
  oauth2UserTokenExchange,
  oauth2JWTBearer,
  oauth2AuthorizationCode,
  oauth2Password,
  oauth2TechnicalUserPropagation,
  clientCertificateAuthentication,
  samlAssertion,
  principalPropagation,
  oauth2MtlsClientCredentials,
}

/// Proxy type for network routing.
enum ProxyType
{
  internet,
  onPremise,
  privateLink,
}

/// Level at which the destination is defined.
enum DestinationLevel
{
  subaccount,
  serviceInstance,
}

/// Certificate type for keystore/truststore management.
enum CertificateType
{
  keystore,
  truststore,
}

/// Certificate format.
enum CertificateFormat
{
  p12,
  jks,
  pem,
  pfx,
}

/// Status of a certificate.
enum CertificateStatus
{
  valid,
  expiring,
  expired,
  invalid_,
}

/// Status of a destination configuration.
enum DestinationStatus
{
  active,
  inactive,
  error,
}

/// Status of an auth-token resolution.
enum TokenStatus
{
  valid,
  expired,
  error,
}

/// HTTP method used during destination health checks or probing.
enum HttpMethod
{
  get_,
  post_,
  put_,
  delete_,
  patch_,
  head_,
  options_,
}
