module uim.platform.connectivity.domain.types;

/// Unique identifier type aliases for type safety.
alias DestinationId = string;
alias ConnectorId = string;
alias ChannelId = string;
alias RuleId = string;
alias CertificateId = string;
alias ConnectivityLogId = string;
alias TenantId = string;
alias SubaccountId = string;

/// Destination protocol type.
enum DestinationType
{
  http,
  rfc,
  mail,
  ldap,
}

/// Authentication method for destinations.
enum AuthenticationType
{
  noAuthentication,
  basicAuthentication,
  oauth2ClientCredentials,
  oauth2SAMLBearerAssertion,
  oauth2UserTokenExchange,
  oauth2JWTBearer,
  oauth2Password,
  oauth2AuthorizationCode,
  clientCertificateAuthentication,
  principalPropagation,
  samlAssertion,
}

/// Proxy type for destination routing.
enum ProxyType
{
  internet,
  onPremise,
  privateLink,
}

/// Cloud Connector connection status.
enum ConnectorStatus
{
  connected,
  disconnected,
  error,
  maintenance,
}

/// Service channel protocol type.
enum ChannelType
{
  http,
  rfc,
  tcp,
}

/// Service channel status.
enum ChannelStatus
{
  open,
  closed,
  error,
}

/// Access rule policy.
enum AccessPolicy
{
  allow,
  deny,
}

/// Protocol for access rules.
enum AccessProtocol
{
  http,
  https,
  rfc,
  tcp,
  ldap,
}

/// Certificate format type.
enum CertificateType
{
  x509,
  pkcs12,
  pem,
  jks,
}

/// Certificate usage purpose.
enum CertificateUsage
{
  authentication,
  signing,
  encryption,
}

/// Connectivity log event severity.
enum LogSeverity
{
  info,
  warning,
  error,
  critical,
}

/// Connectivity log event type.
enum ConnectivityEventType
{
  connectionEstablished,
  connectionLost,
  connectionRefused,
  authenticationSuccess,
  authenticationFailure,
  certificateExpiring,
  certificateExpired,
  channelOpened,
  channelClosed,
  channelError,
  accessDenied,
  accessGranted,
  healthCheckPassed,
  healthCheckFailed,
  destinationResolved,
  destinationNotFound,
}
