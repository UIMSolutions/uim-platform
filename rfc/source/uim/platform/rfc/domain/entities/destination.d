/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.entities.destination;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// An RFC Destination represents a connection profile to a remote SAP or non-SAP system.
/// Corresponds to SM59 transaction entries in SAP NetWeaver / S/4HANA.
/// See: SAP documentation section "RFC Administration".
struct Destination {
    DestinationId  id;             /// Destination name (unique key in SM59)
    string         tenantId;
    ConnectionType connectionType; /// SM59 category (ABAP, HTTP, TCP/IP, etc.)
    string         description;    /// Short text description
    string         host;           /// Target hostname or IP address
    ushort         port;           /// Target port (typically 33xx for ABAP systems)
    SystemId       systemId;       /// SAP System ID (SID), 3 chars
    string         systemNumber;   /// ABAP system number (00-99)
    string         client;         /// SAP client number (000-999)
    string         language;       /// Logon language (DE, EN, …)
    string         logonUser;      /// RFC logon user (stored as reference; no passwords here)
    bool           useSNC;         /// Secure Network Communication enabled
    bool           active;         /// Whether this destination is currently active
    long           createdAt;
    long           updatedAt;

    bool isNull() const { return id.length == 0; }

    Json toJson() const {
        return Json.emptyObject
            .set("id",             id)
            .set("tenantId",       tenantId)
            .set("connectionType", to!string(connectionType))
            .set("description",    description)
            .set("host",           host)
            .set("port",           cast(long) port)
            .set("systemId",       systemId)
            .set("systemNumber",   systemNumber)
            .set("client",         client)
            .set("language",       language)
            .set("logonUser",      logonUser)
            .set("useSNC",         useSNC)
            .set("active",         active)
            .set("createdAt",      createdAt)
            .set("updatedAt",      updatedAt);
    }

    static Destination create(string id, string tenantId, ConnectionType ct, string host) {
        import core.time : MonoTime;
        Destination d;
        d.id             = id;
        d.tenantId       = tenantId;
        d.connectionType = ct;
        d.host           = host;
        d.port           = 3300;
        d.active         = true;
        d.createdAt      = MonoTime.currTime.ticks;
        d.updatedAt      = d.createdAt;
        return d;
    }
}
