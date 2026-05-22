/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.services.queue_processor;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// Processes entries from a qRFC/bgRFC queue in sequence-number order.
///
/// qRFC extends tRFC by guaranteeing that LUWs within a named queue are
/// executed strictly in the order they were enqueued. This service retrieves
/// all pending entries for a queue, sorts them by sequenceNr, and processes
/// them via the RfcExecutor.
struct QueueProcessor {

    private RfcQueueRepository  _queueRepo;
    private RfcCallRepository   _callRepo;
    private DestinationRepository _destRepo;
    private FunctionModuleRepository _fmRepo;
    private RfcExecutor         _executor;
    private TidManager          _tidManager;

    this(RfcQueueRepository queueRepo, RfcCallRepository callRepo,
         DestinationRepository destRepo, FunctionModuleRepository fmRepo,
         TidManager tidManager) {
        _queueRepo  = queueRepo;
        _callRepo   = callRepo;
        _destRepo   = destRepo;
        _fmRepo     = fmRepo;
        _tidManager = tidManager;
        _executor   = RfcExecutor();
    }

    /// Process all pending entries of the given queue in order.
    /// Returns the number of successfully processed entries.
    int processQueue(string tenantId, QueueName queueName) @trusted {
        import std.algorithm : sort;
        auto entries = _queueRepo.findPending(tenantId, queueName);

        // Sort by sequenceNr ascending
        entries.sort!((a, b) => a.sequenceNr < b.sequenceNr);

        int processed = 0;
        foreach (ref entry; entries) {
            auto call = _callRepo.findById(tenantId, entry.callId);
            if (call.isNull()) continue;

            auto dest = _destRepo.findById(tenantId, call.destinationId);
            if (dest.isNull()) continue;

            auto fm = _fmRepo.findById(tenantId, call.functionModule);
            if (fm.isNull()) continue;

            // Duplicate TID check
            if (_tidManager.isDuplicate(tenantId, entry.tid)) {
                entry.status    = RfcStatus.succeeded;
                entry.processedAt = _nowTicks();
                _queueRepo.update(entry);
                processed++;
                continue;
            }

            _tidManager.beginExecution(tenantId, entry.tid);

            call.status     = RfcStatus.executing;
            call.executedAt = _nowTicks();
            _callRepo.update(call);

            auto result = _executor.execute(call, dest, fm);
            import core.time : MonoTime;

            if (result.success) {
                call.status       = RfcStatus.succeeded;
                call.exportParams = result.exportParams.dup;
                call.completedAt  = _nowTicks();
                _callRepo.update(call);

                entry.status      = RfcStatus.succeeded;
                entry.processedAt = _nowTicks();
                _queueRepo.update(entry);

                _tidManager.commit(tenantId, entry.tid);
                processed++;
            } else {
                call.status       = RfcStatus.failed;
                call.errorMessage = result.message;
                call.completedAt  = _nowTicks();
                _callRepo.update(call);

                entry.status      = RfcStatus.failed;
                entry.processedAt = _nowTicks();
                _queueRepo.update(entry);

                _tidManager.rollback(tenantId, entry.tid);
                // Stop queue processing on first failure (preserve ordering guarantee)
                break;
            }
        }
        return processed;
    }

private:
    long _nowTicks() @trusted {
        import core.time : MonoTime;
        return MonoTime.currTime.ticks;
    }
}
