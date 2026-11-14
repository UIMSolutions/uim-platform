/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.dtos.specs;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

// ── Destinations ─────────────────────────────────────────────────────────────

struct DestinationSpec {
  string name;
  string description;
  string url;
  DestinationType destinationType = DestinationType.http;
  AuthenticationType authenticationType = AuthenticationType.noAuthentication;
  ProxyType proxyType = ProxyType.internet;
  string user;
  string password;
  string clientId;
  string clientSecret;
  string tokenServiceUrl;
  string tokenServiceUser;
  string tokenServicePassword;
  CertificateId certificateId; /// id or certificate name
  string cloudConnectorLocationId;
  KeyValue[] properties;
  KeyValue[] additionalHeaders;
}

alias CreateDestinationRequest = CreateRootRequest!DestinationSpec;
alias UpdateDestinationRequest = UpdateRequest!(DestinationId, DestinationSpec);

// ── Cloud Connectors ─────────────────────────────────────────────────────────

struct ConnectorSpec {
  SubaccountId subaccountId;
  string name;
  string locationId;
  string description;
  string connectorVersion;
  string host;
  int port = 8443;
  string tunnelEndpoint;
}

alias RegisterConnectorRequest = CreateRootRequest!ConnectorSpec;
alias UpdateConnectorRequest = UpdateRequest!(ConnectorId, ConnectorSpec);

// ── Service channels (parent = connector) ────────────────────────────────────

struct ChannelSpec {
  string name;
  string description;
  ChannelType channelType = ChannelType.http;
  string virtualHost;
  int virtualPort;
  string backendHost;
  int backendPort;
  int connectionCount = 1;
}

alias CreateChannelRequest = CreateRequest!(ConnectorId, ChannelSpec);
alias UpdateChannelRequest = UpdateRequest!(ChannelId, ChannelSpec);

// ── Access rules (parent = connector) ────────────────────────────────────────

struct AccessRuleSpec {
  string name; /// "" = derived from the mapping
  string description;
  AccessProtocol protocol = AccessProtocol.https;
  string virtualHost;
  int virtualPort;
  string internalHost;
  int internalPort;
  string urlPathPrefix = "/";
  bool includeSubPaths = true;
  AccessPolicy policy = AccessPolicy.allow;
  bool principalPropagation;
  bool enabled = true;
}

alias CreateAccessRuleRequest = CreateRequest!(ConnectorId, AccessRuleSpec);
alias UpdateAccessRuleRequest = UpdateRequest!(AccessRuleId, AccessRuleSpec);

// ── Certificates ─────────────────────────────────────────────────────────────

struct CertificateSpec {
  string name;
  string description;
  CertificateType certificateType = CertificateType.x509;
  CertificateUsage usage = CertificateUsage.authentication;
  string subjectDN;
  string issuerDN;
  string serialNumber;
  string fingerprint;
  long issuedAt;
  long expiresAt;
}

alias CreateCertificateRequest = CreateRootRequest!CertificateSpec;
alias UpdateCertificateRequest = UpdateRequest!(CertificateId, CertificateSpec);

// ── Log entries (external events) ────────────────────────────────────────────

struct LogEntrySpec {
  ConnectivityEventType eventType = ConnectivityEventType.configurationChanged;
  LogSeverity severity = LogSeverity.info;
  SourceType sourceType = SourceType.service;
  string sourceId;
  string sourceName;
  string message;
  string remoteHost;
  int remotePort;
  long occurredAt; /// 0 = now
}

alias CreateLogEntryRequest = CreateRootRequest!LogEntrySpec;
alias UpdateLogEntryRequest = UpdateRequest!(LogEntryId, LogEntrySpec);
