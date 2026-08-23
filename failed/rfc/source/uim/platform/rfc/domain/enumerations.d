/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.enumerations;

import uim.platform.rfc;

mixin(ShowModule!());

@safe:


// ---------------------------------------------------------------------------
// RFC variant types (SAP S/4HANA 1709 — 4888068ad9134076e10000000a42189d)
// ---------------------------------------------------------------------------
enum RfcType {
    sRFC,   /// Synchronous RFC — both systems must be available; caller waits for result
    aRFC,   /// Asynchronous RFC — control returns immediately; called system must be up
    tRFC,   /// Transactional RFC — exactly-once, uses TID; called system can be down
    qRFC,   /// Queued RFC — tRFC with guaranteed LUW ordering via named queues
    bgRFC,  /// Background RFC — successor to tRFC/qRFC; recommended for new development
    ldq     /// Local Data Queue — pull-based variant; data stored locally until retrieved
}
RfcType toRfcType(string s) {
  switch(s.lower) {
    case "srf": case "srfc": return RfcType.sRFC;
    case "arf": case "arfc": return RfcType.aRFC;
    case "trf": case "trfc": return RfcType.tRFC;
    case "qrf": case "qrfc": return RfcType.qRFC;
    case "bgrf": case "bgrfc": return RfcType.bgRFC;
    case "ldq": return RfcType.ldq;
    default: return RfcType.sRFC;
  }
}

// ---------------------------------------------------------------------------
// RFC call status lifecycle
// ---------------------------------------------------------------------------
enum RfcStatus {
    pending,        /// Created, not yet dispatched
    executing,      /// In-flight (sRFC / aRFC)
    queued,         /// Stored in queue (qRFC inbound/outbound)
    committed,      /// tRFC/qRFC LUW committed
    rolledBack,     /// LUW rolled back
    succeeded,      /// Call completed successfully
    failed,         /// Call failed with error
    timedOut        /// No response within deadline
}
RfcStatus toRfcStatus(string s) {
  switch(s.lower) {
    case "pending": return RfcStatus.pending;
    case "executing": return RfcStatus.executing;
    case "queued": return RfcStatus.queued;
    case "committed": return RfcStatus.committed;
    case "rolledback": return RfcStatus.rolledBack;
    case "succeeded": return RfcStatus.succeeded;
    case "failed": return RfcStatus.failed;
    case "timedout": return RfcStatus.timedOut;
    default: return RfcStatus.pending;
  }
}
// ---------------------------------------------------------------------------
// RFC parameter direction (mirrors ABAP function-module interface)
// ---------------------------------------------------------------------------
enum ParameterDirection {
    import_,    /// Caller → Callee (IMPORTING in ABAP)
    export_,    /// Callee → Caller (EXPORTING in ABAP)
    changing,   /// Bidirectional (CHANGING in ABAP)
    tables      /// Internal tables (TABLES in ABAP)
}
ParameterDirection toParameterDirection(string s) {
  switch(s.lower) {
    case "import": return ParameterDirection.import_;
    case "export": return ParameterDirection.export_;
    case "changing": return ParameterDirection.changing;
    case "tables": return ParameterDirection.tables;
    default: return ParameterDirection.import_;
  }
}

// ---------------------------------------------------------------------------
// RFC destination connection type (SM59 category)
// ---------------------------------------------------------------------------
enum ConnectionType {
    abapSystem,         /// Type 3 — ABAP connection (R/3 / S/4HANA)
    httpConnection,     /// Type H — HTTP connection
    tcpIpConnection,    /// Type T — TCP/IP (e.g., RFC SDK server program)
    logicalDestination, /// Type L — Logical destination (balanced group)
    internalCall,       /// Type I — Internal (same system)
    sncDestination      /// Type X — SNC-secured connection
}
ConnectionType toConnectionType(string s) {
  switch(s.lower) {
    case "abap": case "abapsystem": return ConnectionType.abapSystem;
    case "http": case "httpconnection": return ConnectionType.httpConnection;
    case "tcpip": case "tcpipconnection": return ConnectionType.tcpIpConnection;
    case "logical": case "logicaldestination": return ConnectionType.logicalDestination;
    case "internal": case "internalcall": return ConnectionType.internalCall;
    case "snc": case "sncdestination": return ConnectionType.sncDestination;
    default: return ConnectionType.abapSystem;
  }
}

// ---------------------------------------------------------------------------
// Queue direction (qRFC)
// ---------------------------------------------------------------------------
enum QueueDirection {
    outbound,   /// Outbound queue (sender side)
    inbound     /// Inbound queue (receiver side)
}
QueueDirection toQueueDirection(string s) {
  switch(s.lower) {
    case "outbound": return QueueDirection.outbound;
    case "inbound": return QueueDirection.inbound;
    default: return QueueDirection.outbound;
  }
}

// ---------------------------------------------------------------------------
// Logical Unit of Work (LUW) state for tRFC/qRFC
// ---------------------------------------------------------------------------
enum LuwStatus {
    open,
    executing,
    committed,
    rolledBack
}
LuwStatus toLuwStatus(string s) {
  switch(s.lower) {
    case "open": return LuwStatus.open;
    case "executing": return LuwStatus.executing;
    case "committed": return LuwStatus.committed;
    case "rolledback": return LuwStatus.rolledBack;
    default: return LuwStatus.open;
  }
}

// ---------------------------------------------------------------------------
// bgRFC unit type
// ---------------------------------------------------------------------------
enum BgRfcUnitType {
    noc,    /// No-commit unit — processing in the same LUW as the caller
    que     /// Queued unit — with serialisation guarantee
}
BgRfcUnitType toBgRfcUnitType(string s) {
  switch(s.lower) {
    case "noc": return BgRfcUnitType.noc;
    case "que": return BgRfcUnitType.que;
    default: return BgRfcUnitType.noc;
  }
}