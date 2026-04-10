/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.types;

/// Unique identifier type aliases for type safety.
struct DestinationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ConnectorId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ChannelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct CertificateId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ConnectivityLogId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct TenantId = string;
struct SubaccountId = string;

/// Destination protocol type.
enum DestinationType {
  http,
  rfc,
  mail,
  ldap,
}

/// Authentication method for destinations.
enum AuthenticationType {
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
enum ProxyType {
  internet,
  onPremise,
  privateLink,
}

/// Cloud Connector connection status.
enum ConnectorStatus {
  connected,
  disconnected,
  error,
  maintenance,
}

/// Service channel protocol type.
enum ChannelType {
  http,
  rfc,
  tcp,
}

/// Service channel status.
enum ChannelStatus {
  open,
  closed,
  error,
}

/// Access rule policy.
enum AccessPolicy {
  allow,
  deny,
}

/// Protocol for access rules.
enum AccessProtocol {
  http,
  https,
  rfc,
  tcp,
  ldap,
}

/// Certificate format type.
enum CertificateType {
  x509,
  pkcs12,
  pem,
  jks,
}

/// Certificate usage purpose.
enum CertificateUsage {
  authentication,
  signing,
  encryption,
}

/// Connectivity log event severity.
enum LogSeverity {
  info,
  warning,
  error,
  critical,
}

/// Connectivity log event type.
enum ConnectivityEventType {
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
