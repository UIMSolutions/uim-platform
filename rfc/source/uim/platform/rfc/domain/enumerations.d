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

// ---------------------------------------------------------------------------
// RFC parameter direction (mirrors ABAP function-module interface)
// ---------------------------------------------------------------------------
enum ParameterDirection {
    import_,    /// Caller → Callee (IMPORTING in ABAP)
    export_,    /// Callee → Caller (EXPORTING in ABAP)
    changing,   /// Bidirectional (CHANGING in ABAP)
    tables      /// Internal tables (TABLES in ABAP)
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

// ---------------------------------------------------------------------------
// Queue direction (qRFC)
// ---------------------------------------------------------------------------
enum QueueDirection {
    outbound,   /// Outbound queue (sender side)
    inbound     /// Inbound queue (receiver side)
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

// ---------------------------------------------------------------------------
// bgRFC unit type
// ---------------------------------------------------------------------------
enum BgRfcUnitType {
    noc,    /// No-commit unit — processing in the same LUW as the caller
    que     /// Queued unit — with serialisation guarantee
}
