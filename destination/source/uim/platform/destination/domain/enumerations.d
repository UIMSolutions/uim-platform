/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module  uim.platform.destination.domain.enumerations;

import uim.platform.destination;

mixin(ShowModule!());

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
AuthenticationType toAuthenticationType(string value) {
  mixin(EnumSwitch("AuthenticationType", "noAuthentication"));
}   
AuthenticationType[] toAuthenticationTypes(string[] types) {
  return types.map!(t => toAuthenticationType(t)).array;
}
string toString(AuthenticationType type) {
  return type.to!string;
}
string[] toStrings(AuthenticationType[] types) {
  return types.map!(t => t.to!string).array;
}
///
unittest {
  mixin(ShowTest!("AuthenticationType"));

  assert("noAuthentication".toAuthenticationType == AuthenticationType.noAuthentication);
  assert("basicAuthentication".toAuthenticationType == AuthenticationType.basicAuthentication);
  assert("oauth2ClientCredentials".toAuthenticationType == AuthenticationType.oauth2ClientCredentials);
  assert("oauth2SAMLBearerAssertion".toAuthenticationType == AuthenticationType.oauth2SAMLBearerAssertion);
  assert("oauth2UserTokenExchange".toAuthenticationType == AuthenticationType.oauth2UserTokenExchange);
  assert("oauth2JWTBearer".toAuthenticationType == AuthenticationType.oauth2JWTBearer);
  assert("oauth2AuthorizationCode".toAuthenticationType == AuthenticationType.oauth2AuthorizationCode);
  assert("oauth2Password".toAuthenticationType == AuthenticationType.oauth2Password);
  assert("oauth2TechnicalUserPropagation".toAuthenticationType == AuthenticationType.oauth2TechnicalUserPropagation);
  assert("clientCertificateAuthentication".toAuthenticationType == AuthenticationType.clientCertificateAuthentication);
  assert("samlAssertion".toAuthenticationType == AuthenticationType.samlAssertion);
  assert("principalPropagation".toAuthenticationType == AuthenticationType.principalPropagation);
  assert("oauth2MtlsClientCredentials".toAuthenticationType == AuthenticationType.oauth2MtlsClientCredentials);

  assert("".toAuthenticationType == AuthenticationType.noAuthentication); // Default case
  assert("unknown".toAuthenticationType == AuthenticationType.noAuthentication); // Default case

  assert(AuthenticationType.noAuthentication.toString == "noAuthentication");
  assert(AuthenticationType.basicAuthentication.toString == "basicAuthentication");
  assert(AuthenticationType.oauth2ClientCredentials.toString == "oauth2ClientCredentials");
  assert(AuthenticationType.oauth2SAMLBearerAssertion.toString == "oauth2SAMLBearerAssertion");
  assert(AuthenticationType.oauth2UserTokenExchange.toString == "oauth2UserTokenExchange");
  assert(AuthenticationType.oauth2JWTBearer.toString == "oauth2JWTBearer");
  assert(AuthenticationType.oauth2AuthorizationCode.toString == "oauth2AuthorizationCode");
  assert(AuthenticationType.oauth2Password.toString == "oauth2Password");
  assert(AuthenticationType.oauth2TechnicalUserPropagation.toString == "oauth2TechnicalUserPropagation");
  assert(AuthenticationType.clientCertificateAuthentication.toString == "clientCertificateAuthentication");
  assert(AuthenticationType.samlAssertion.toString == "samlAssertion");
  assert(AuthenticationType.principalPropagation.toString == "principalPropagation");
  assert(AuthenticationType.oauth2MtlsClientCredentials.toString == "oauth2MtlsClientCredentials");
  
  assert([AuthenticationType.noAuthentication, AuthenticationType.basicAuthentication].toStrings == ["noAuthentication", "basicAuthentication"]);
  assert(["noAuthentication", "basicAuthentication"].toAuthenticationTypes == [AuthenticationType.noAuthentication, AuthenticationType.basicAuthentication]);
} 

/// Proxy type for network routing.
enum ProxyType {
  internet, // Direct connection to the destination without a proxy.
  onPremise, // Connection to the destination through an on-premise connectivity agent (e.g., SAP Cloud Connector).
  privateLink, // Connection to the destination through a private link (e.g., AWS PrivateLink, Azure Private Link).
  privateNetwork // Connection to the destination through a private network (e.g., SAP Cloud Hub).
}
ProxyType toProxyType(string value) {
  mixin(EnumSwitch("ProxyType", "internet"));
}
ProxyType[] toProxyTypes(string[] types) {
  return types.map!toProxyType.array;
}
string toString(ProxyType type) {
  return type.to!string;
}
string[] toStrings(ProxyType[] types) {
  return types.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ProxyType"));

  assert("internet".toProxyType == ProxyType.internet);
  assert("onPremise".toProxyType == ProxyType.onPremise);
  assert("privateLink".toProxyType == ProxyType.privateLink);
  assert("privateNetwork".toProxyType == ProxyType.privateNetwork);

  assert("".toProxyType == ProxyType.internet); // Default case
  assert("unknown".toProxyType == ProxyType.internet); // Default case

  assert(ProxyType.internet.toString == "internet");
  assert(ProxyType.onPremise.toString == "onPremise");
  assert(ProxyType.privateLink.toString == "privateLink");
  assert(ProxyType.privateNetwork.toString == "privateNetwork");

  assert([ProxyType.internet, ProxyType.onPremise].toStrings == ["internet", "onPremise"]);
  assert(["internet", "onPremise"].toProxyTypes == [ProxyType.internet, ProxyType.onPremise]);
}

/// Level at which the destination is defined.
enum DestinationLevel {
  subaccount,
  serviceInstance,
}
DestinationLevel toDestinationLevel(string value) {
  mixin(EnumSwitch("DestinationLevel", "subaccount"));
}
DestinationLevel[] toDestinationLevels(string[] levels) {
  return levels.map!toDestinationLevel.array;
}
string toString(DestinationLevel level) {
  return level.to!string;
}
string[] toStrings(DestinationLevel[] levels) {
  return levels.map!toString.array;
} 
///
unittest {
  mixin(ShowTest!("DestinationLevel"));

  assert("subaccount".toDestinationLevel == DestinationLevel.subaccount);
  assert("serviceInstance".toDestinationLevel == DestinationLevel.serviceInstance);

  assert("".toDestinationLevel == DestinationLevel.subaccount); // Default case
  assert("unknown".toDestinationLevel == DestinationLevel.subaccount); // Default case

  assert(DestinationLevel.subaccount.toString == "subaccount");
  assert(DestinationLevel.serviceInstance.toString == "serviceInstance");

  assert([DestinationLevel.subaccount, DestinationLevel.serviceInstance].toStrings == ["subaccount", "serviceInstance"]);
  assert(["subaccount", "serviceInstance"].toDestinationLevels == [DestinationLevel.subaccount, DestinationLevel.serviceInstance]);
}

/// Certificate type for keystore/truststore management.
enum CertificateType {
  keystore,
  truststore,
}
CertificateType toCertificateType(string value) {
  mixin(EnumSwitch("CertificateType", "keystore"));
}
CertificateType[] toCertificateTypes(string[] types) {
  return types.map!toCertificateType.array;
}
string toString(CertificateType type) {
  return type.to!string;
}
string[] toStrings(CertificateType[] types) {
  return types.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("CertificateType"));

  assert("keystore".toCertificateType == CertificateType.keystore);
  assert("truststore".toCertificateType == CertificateType.truststore);

  assert("".toCertificateType == CertificateType.keystore); // Default case
  assert("unknown".toCertificateType == CertificateType.keystore); // Default case

  assert(CertificateType.keystore.toString == "keystore");
  assert(CertificateType.truststore.toString == "truststore");

  assert([CertificateType.keystore, CertificateType.truststore].toStrings == ["keystore", "truststore"]);
  assert(["keystore", "truststore"].toCertificateTypes == [CertificateType.keystore, CertificateType.truststore]);
}

/// Certificate format.
enum CertificateFormat {
  p12,
  jks,
  pem,
  pfx,
}
CertificateFormat toCertificateFormat(string value) {
  mixin(EnumSwitch("CertificateFormat", "p12"));
}
CertificateFormat[] toCertificateFormats(string[] formats) {
  return formats.map!toCertificateFormat.array;
}
string toString(CertificateFormat format) {
  return format.to!string;
}
string[] toStrings(CertificateFormat[] formats) {
  return formats.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("CertificateFormat"));

  assert("p12".toCertificateFormat == CertificateFormat.p12);
  assert("jks".toCertificateFormat == CertificateFormat.jks);
  assert("pem".toCertificateFormat == CertificateFormat.pem);
  assert("pfx".toCertificateFormat == CertificateFormat.pfx);

  assert("".toCertificateFormat == CertificateFormat.p12); // Default case
  assert("unknown".toCertificateFormat == CertificateFormat.p12); // Default case

  assert(CertificateFormat.p12.toString == "p12");
  assert(CertificateFormat.jks.toString == "jks");
  assert(CertificateFormat.pem.toString == "pem");
  assert(CertificateFormat.pfx.toString == "pfx");

  assert([CertificateFormat.p12, CertificateFormat.jks].toStrings == ["p12", "jks"]);
  assert(["p12", "jks"].toCertificateFormats == [CertificateFormat.p12, CertificateFormat.jks]);
}

/// Status of a certificate.
enum CertificateStatus : string{
  valid = "valid",
  expiring = "expiring",
  expired = "expired",
  invalid_ = "invalid",
}
CertificateStatus toCertificateStatus(string value) {
  switch (value.toLower) {
    case "valid": return CertificateStatus.valid;
    case "expiring": return CertificateStatus.expiring;
    case "expired": return CertificateStatus.expired;
    case "invalid": return CertificateStatus.invalid_;
    default: return CertificateStatus.valid; // Default to valid if not found
  }
}
CertificateStatus[] toCertificateStatuses(string[] statuses) {
  return statuses.map!toCertificateStatus.array;
}
string toString(CertificateStatus status) {
 return cast(string)status;
}
string[] toStrings(CertificateStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("CertificateStatus"));

  assert("valid".toCertificateStatus == CertificateStatus.valid);
  assert("expiring".toCertificateStatus == CertificateStatus.expiring);
  assert("expired".toCertificateStatus == CertificateStatus.expired);
  assert("invalid".toCertificateStatus == CertificateStatus.invalid_);

  assert("".toCertificateStatus == CertificateStatus.valid); // Default case
  assert("unknown".toCertificateStatus == CertificateStatus.valid); // Default case

  assert(CertificateStatus.valid.toString == "valid");
  assert(CertificateStatus.expiring.toString == "expiring");
  assert(CertificateStatus.expired.toString == "expired");
  assert(CertificateStatus.invalid_.toString == "invalid");

  assert([CertificateStatus.valid, CertificateStatus.expiring].toStrings == ["valid", "expiring"]);
  assert(["valid", "expiring"].toCertificateStatuses == [CertificateStatus.valid, CertificateStatus.expiring]);
}

/// Status of a destination configuration.
enum DestinationStatus {
  active,
  inactive,
  error,
}
DestinationStatus toDestinationStatus(string value) {
  mixin(EnumSwitch("DestinationStatus", "active"));
}
DestinationStatus[] toDestinationStatuses(string[] statuses) {
  return statuses.map!toDestinationStatus.array;
}
string toString(DestinationStatus status) {
  return status.to!string;
}
string[] toStrings(DestinationStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DestinationStatus"));

  assert("active".toDestinationStatus == DestinationStatus.active);
  assert("inactive".toDestinationStatus == DestinationStatus.inactive);
  assert("error".toDestinationStatus == DestinationStatus.error);

  assert("".toDestinationStatus == DestinationStatus.active); // Default case
  assert("unknown".toDestinationStatus == DestinationStatus.active); // Default case

  assert(DestinationStatus.active.toString == "active");
  assert(DestinationStatus.inactive.toString == "inactive");
  assert(DestinationStatus.error.toString == "error");

  assert([DestinationStatus.active, DestinationStatus.inactive].toStrings == ["active", "inactive"]);
  assert(["active", "inactive"].toDestinationStatuses == [DestinationStatus.active, DestinationStatus.inactive]);
}

/// Status of an auth-token resolution.
enum TokenStatus {
  valid,
  expired,
  error,
}
TokenStatus toTokenStatus(string value) {
  mixin(EnumSwitch("TokenStatus", "valid"));
}
TokenStatus[] toTokenStatuses(string[] statuses) {
  return statuses.map!toTokenStatus.array;
}
string toString(TokenStatus status) {
  return status.to!string;
}
string[] toStrings(TokenStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("TokenStatus"));

  assert("valid".toTokenStatus == TokenStatus.valid);
  assert("expired".toTokenStatus == TokenStatus.expired);
  assert("error".toTokenStatus == TokenStatus.error);

  assert("".toTokenStatus == TokenStatus.valid); // Default case
  assert("unknown".toTokenStatus == TokenStatus.valid); // Default case

  assert(TokenStatus.valid.toString == "valid");
  assert(TokenStatus.expired.toString == "expired");
  assert(TokenStatus.error.toString == "error");

  assert([TokenStatus.valid, TokenStatus.expired].toStrings == ["valid", "expired"]);
  assert(["valid", "expired"].toTokenStatuses == [TokenStatus.valid, TokenStatus.expired]);
}

/// Type of destination connection.
enum DestinationType {
  http,
  rfc,
  mail,
  ldap,
}
DestinationType toDestinationType(string value) {
  mixin(EnumSwitch("DestinationType", "http"));
}
DestinationType[] toDestinationTypes(string[] types) {
  return types.map!toDestinationType.array;
}
string toString(DestinationType type) {
  return type.to!string;
}
string[] toStrings(DestinationType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DestinationType"));

  assert("http".toDestinationType == DestinationType.http);
  assert("rfc".toDestinationType == DestinationType.rfc);
  assert("mail".toDestinationType == DestinationType.mail);
  assert("ldap".toDestinationType == DestinationType.ldap);

  assert("".toDestinationType == DestinationType.http); // Default case
  assert("unknown".toDestinationType == DestinationType.http); // Default case

  assert(DestinationType.http.toString == "http");
  assert(DestinationType.rfc.toString == "rfc");
  assert(DestinationType.mail.toString == "mail");
  assert(DestinationType.ldap.toString == "ldap");

  assert([DestinationType.http, DestinationType.rfc].toStrings == ["http", "rfc"]);
  assert(["http", "rfc"].toDestinationTypes == [DestinationType.http, DestinationType.rfc]);
}
