/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A system of the customer landscape that takes part in integration
/// scenarios (source or target of a workflow).
module uim.platform.integration_automation.domain.entities.system_connection;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct SystemConnection {
  mixin TenantEntity!SystemConnectionId;

  string name; /// e.g. "S/4HANA Cloud Production"
  string description;
  SystemType systemType = SystemType.s4HanaCloud;
  string host; /// host name or IP address
  int port = 443;
  string protocol = "https"; /// https | http | rfc
  string client; /// SAP client (3 digits), optional
  string sid; /// SAP system id (3 characters), optional
  SystemEnvironment environment = SystemEnvironment.production;
  string region; /// e.g. "eu10"
  ConnectionStatus status = ConnectionStatus.inactive;
  long lastTestedAt;
  string lastTestMessage;

  /// Record the result of a connection test.
  void recordTest(bool reachable, string message, long at) {
    status = reachable ? ConnectionStatus.active : ConnectionStatus.error;
    lastTestMessage = message;
    lastTestedAt = at;
  }

  void validate() const {
    requireId(id.value, "System ID");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 2000, "Description");
    if (systemType == SystemType.any_)
      throw IaException.invalid("A system must have a concrete system type, not 'any'");
    requireText(host, "Host");
    requireMaxLength(host, 253, "Host");
    if (host.canFind!(c => c == ' ' || c == '/' || c == '?' || c == '#'))
      throw IaException.invalid("Host '" ~ host ~ "' must be a host name or IP address (no scheme or path)");
    requireRange(port, 1, 65_535, "Port");
    if (!["https", "http", "rfc"].canFind(protocol))
      throw IaException.invalid("Protocol '" ~ protocol ~ "' must be https, http or rfc");
    if (client.length && (client.length != 3 || !client.all!(c => c >= '0' && c <= '9')))
      throw IaException.invalid("Client '" ~ client ~ "' must have three digits (e.g. 100)");
    if (sid.length && (sid.length != 3 || !sid.all!(c => (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9'))))
      throw IaException.invalid("SID '" ~ sid ~ "' must have three upper case letters or digits (e.g. S4P)");
    requireMaxLength(region, 64, "Region");
  }
}

///
unittest {
  SystemConnection s;
  s.id = SystemConnectionId("s4-prd");
  s.name = "S/4HANA Cloud";
  s.host = "my300000.s4hana.cloud.sap";
  s.client = "100";
  s.sid = "S4P";
  s.validate();
  s.recordTest(true, "reachable", 5);
  assert(s.status == ConnectionStatus.active && s.lastTestedAt == 5);
  s.host = "https://x/y";
  assert(failsWith(IaErrorKind.invalid, () { s.validate(); }));
  s.host = "x";
  s.client = "1";
  assert(failsWith(IaErrorKind.invalid, () { s.validate(); }));
  s.client = "";
  s.systemType = SystemType.any_;
  assert(failsWith(IaErrorKind.invalid, () { s.validate(); }));
}
