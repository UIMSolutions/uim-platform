module uim.platform.destination.domain.enumerations;
import uim.platform.destination;

// mixin(ShowModule!());

@safe:
/// Authentication method for the destination.
enum AuthenticationType {
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
AuthenticationType toAuthenticationType(string s) {
  const map = [
    "noauthentication": AuthenticationType.noAuthentication,
    "basicauthentication": AuthenticationType.basicAuthentication,
    "oauth2clientcredentials": AuthenticationType.oauth2ClientCredentials,
    "oauth2samlbearerassertion": AuthenticationType.oauth2SAMLBearerAssertion,
    "oauth2usertokenexchange": AuthenticationType.oauth2UserTokenExchange,
    "oauth2jwtbearer": AuthenticationType.oauth2JWTBearer,
    "oauth2authorizationcode": AuthenticationType.oauth2AuthorizationCode,
    "oauth2password": AuthenticationType.oauth2Password,    
    "oauth2technicaluserpropagation": AuthenticationType.oauth2TechnicalUserPropagation,
    "clientcertificateauthentication": AuthenticationType.clientCertificateAuthentication,
    "samlassertion": AuthenticationType.samlAssertion,
    "principalpropagation": AuthenticationType.principalPropagation,
    "oauth2mtlsclientcredentials": AuthenticationType.oauth2MtlsClientCredentials,
  ];
  return map.get(s.toLower, AuthenticationType.noAuthentication); // Default to noAuthentication if not found
}   
/// Proxy type for network routing.
enum ProxyType {
  internet, // Direct connection to the destination without a proxy.
  onPremise, // Connection to the destination through an on-premise connectivity agent (e.g., SAP Cloud Connector).
  privateLink, // Connection to the destination through a private link (e.g., AWS PrivateLink, Azure Private Link).
  privateNetwork // Connection to the destination through a private network (e.g., SAP Cloud Hub).
}
ProxyType toProxyType(string s) {
  const map = [
    "internet": ProxyType.internet,
    "onpremise": ProxyType.onPremise,
    "privatelink": ProxyType.privateLink,
    "privatenetwork": ProxyType.privateNetwork,
  ];
  return map.get(s.toLower, ProxyType.internet); // Default to internet if not found
}
/// Level at which the destination is defined.
enum DestinationLevel {
  subaccount,
  serviceInstance,
}
DestinationLevel toDestinationLevel(string s) {
  const map = [
    "subaccount": DestinationLevel.subaccount,
    "serviceinstance": DestinationLevel.serviceInstance,
  ];
  return map.get(s.toLower, DestinationLevel.subaccount); // Default to subaccount if not found
}

/// Certificate type for keystore/truststore management.
enum CertificateType {
  keystore,
  truststore,
}
CertificateType toCertificateType(string s) {
  const map = [
    "keystore": CertificateType.keystore,
    "truststore": CertificateType.truststore,
  ];
  return map.get(s.toLower, CertificateType.keystore); // Default to keystore if not found
}
/// Certificate format.
enum CertificateFormat {
  p12,
  jks,
  pem,
  pfx,
}
CertificateFormat toCertificateFormat(string s) {
  const map = [
    "p12": CertificateFormat.p12,
    "jks": CertificateFormat.jks,
    "pem": CertificateFormat.pem,
    "pfx": CertificateFormat.pfx,
  ];
  return map.get(s.toLower, CertificateFormat.pem); // Default to pem if not found
}
/// Status of a certificate.
enum CertificateStatus {
  valid,
  expiring,
  expired,
  invalid_,
}
CertificateStatus toCertificateStatus(string s) {
  const map = [
    "valid": CertificateStatus.valid,
    "expiring": CertificateStatus.expiring,
    "expired": CertificateStatus.expired,
    "invalid": CertificateStatus.invalid_,
  ];
  return map.get(s.toLower, CertificateStatus.valid); // Default to valid if not found
}
/// Status of a destination configuration.
enum DestinationStatus {
  active,
  inactive,
  error,
}
DestinationStatus toDestinationStatus(string s) {
  const map = [
    "active": DestinationStatus.active,
    "inactive": DestinationStatus.inactive,
    "error": DestinationStatus.error,
  ];
  return map.get(s.toLower, DestinationStatus.active); // Default to active if not found
}
/// Status of an auth-token resolution.
enum TokenStatus {
  valid,
  expired,
  error,
}
TokenStatus toTokenStatus(string s) {
  const map = [
    "valid": TokenStatus.valid,
    "expired": TokenStatus.expired,
    "error": TokenStatus.error,
  ];
  return map.get(s.toLower, TokenStatus.valid); // Default to valid if not found
}

/// Type of destination connection.
enum DestinationType {
  http,
  rfc,
  mail,
  ldap,
}
