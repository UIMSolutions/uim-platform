/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.persistence.mappers.record;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Generic mapper between entities and database records, driven by
/// compile-time reflection (see helpers.codec). Records keep timestamps as raw
/// std-time numbers and enums by name; unknown or missing fields fall back to
/// the entity defaults, so older snapshots stay readable.
struct RecordMapper(TEntity) {
  static Json toRecord(const TEntity entity) {
    return encode(entity, false);
  }

  static TEntity fromRecord(Json record) {
    return decode!TEntity(record);
  }
}

alias DestinationMapper = RecordMapper!Destination;
alias ConnectorMapper = RecordMapper!CloudConnector;
alias ChannelMapper = RecordMapper!ServiceChannel;
alias AccessRuleMapper = RecordMapper!AccessRule;
alias CertificateMapper = RecordMapper!Certificate;
alias LogEntryMapper = RecordMapper!ConnectivityLogEntry;

///
unittest {
  mixin(ShowTest!("RecordMapper"));

  auto d = Destination(TenantId("t1"));
  d.name = "ERP";
  d.authenticationType = AuthenticationType.oauth2ClientCredentials;
  d.proxyType = ProxyType.onPremise;
  d.properties = [KeyValue("sap-client", "100")];
  d.certificateId = CertificateId("c1");
  auto record = DestinationMapper.toRecord(d);
  assert(record["authenticationType"].get!string == "oauth2ClientCredentials");
  assert(record["properties"][0]["key"].get!string == "sap-client");
  assert(record["certificateId"].get!string == "c1");
  assert(record["createdAt"].type == Json.Type.int_);
  assert(DestinationMapper.fromRecord(record) == d);

  auto rule = AccessRule(TenantId("t1"));
  rule.protocol = AccessProtocol.tcpSsl;
  rule.includeSubPaths = false;
  assert(AccessRuleMapper.fromRecord(AccessRuleMapper.toRecord(rule)) == rule);
}
