/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.services.rfc_executor;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

/// Result of executing an RFC call.
struct ExecuteResult {
    bool             success;
    ParameterValue[] exportParams;
    ParameterValue[] changingParams;
    string           errorMessage;
}

/// Domain service that simulates dispatching an RFC call to a remote system.
///
/// In a production integration this service would use the SAP NW RFC SDK or
/// JCo library via a native adapter (infrastructure port). Here it models the
/// RFC variants behaviourally:
///
///   sRFC  — synchronous: executes and returns result immediately (simulated OK)
///   aRFC  — asynchronous: dispatches and returns immediately; result arrives later
///   tRFC  — transactional: records TID, executes exactly once; survives downtime
///   qRFC  — queued: tRFC with ordering guarantee inside a named queue
///   bgRFC — background: successor variant, same behaviour as tRFC/qRFC here
///   ldq   — local data queue: pull-based, data stored locally until retrieved
struct RfcExecutor {

    /// Simulate executing an RFC call.
    /// Returns an ExecuteResult describing the outcome.
    ExecuteResult execute(RfcCall call, Destination dest, FunctionModule fm) @trusted {
        final switch (call.rfcType) {
            case RfcType.sRFC:
                return _executeSynchronous(call, dest, fm);
            case RfcType.aRFC:
                return _executeAsynchronous(call, dest, fm);
            case RfcType.tRFC:
            case RfcType.bgRFC:
                return _executeTransactional(call, dest, fm);
            case RfcType.qRFC:
                return _executeQueued(call, dest, fm);
            case RfcType.ldq:
                return _executeLocalDataQueue(call, dest, fm);
        }
    }

private:
    ExecuteResult _executeSynchronous(RfcCall call, Destination dest, FunctionModule fm) {
        // Synchronous RFC — both systems must be available.
        // Simulated: echo import params back as export params.
        ExecuteResult r;
        r.success      = true;
        r.exportParams = call.importParams.dup;
        return r;
    }

    ExecuteResult _executeAsynchronous(RfcCall call, Destination dest, FunctionModule fm) {
        // aRFC — control returns immediately; the actual execution is fire-and-forget.
        // Called system must be available at dispatch time.
        ExecuteResult r;
        r.success = true;  // Dispatch accepted
        return r;
    }

    ExecuteResult _executeTransactional(RfcCall call, Destination dest, FunctionModule fm) {
        // tRFC — exactly-once guarantee via TID.
        // If TID already committed: skip re-execution (idempotence).
        if (call.tid.length == 0) {
            ExecuteResult r;
            r.success      = false;
            r.errorMessage = "tRFC/bgRFC requires a TID";
            return r;
        }
        ExecuteResult r;
        r.success      = true;
        r.exportParams = call.importParams.dup;
        return r;
    }

    ExecuteResult _executeQueued(RfcCall call, Destination dest, FunctionModule fm) {
        // qRFC — tRFC with queue-based ordering. Queue name is mandatory.
        if (call.queueName.length == 0) {
            ExecuteResult r;
            r.success      = false;
            r.errorMessage = "qRFC requires a queue name";
            return r;
        }
        if (call.tid.length == 0) {
            ExecuteResult r;
            r.success      = false;
            r.errorMessage = "qRFC requires a TID";
            return r;
        }
        ExecuteResult r;
        r.success      = true;
        r.exportParams = call.importParams.dup;
        return r;
    }

    ExecuteResult _executeLocalDataQueue(RfcCall call, Destination dest, FunctionModule fm) {
        // LDQ — pull-based, data stored locally. Execution stores the payload.
        ExecuteResult r;
        r.success = true;
        return r;
    }
}
