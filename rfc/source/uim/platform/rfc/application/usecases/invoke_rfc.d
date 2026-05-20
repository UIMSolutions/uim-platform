/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.application.usecases.invoke_rfc;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// Primary use case: invoke an RFC call against a registered destination.
///
/// Supports all RFC variants:
///   sRFC  — synchronous; returns result directly
///   aRFC  — asynchronous; dispatches and returns accepted immediately
///   tRFC  — transactional; allocates TID, executes exactly once
///   qRFC  — queued; like tRFC but enqueues call for ordered processing
///   bgRFC — background; successor to tRFC/qRFC
///   ldq   — local data queue; stores call for pull-based retrieval
class InvokeRfcUseCase {

    private DestinationRepository    _destRepo;
    private FunctionModuleRepository _fmRepo;
    private RfcCallRepository        _callRepo;
    private TidRepository            _tidRepo;
    private RfcQueueRepository       _queueRepo;
    private RfcExecutor              _executor;
    private TidManager               _tidManager;

    this(DestinationRepository destRepo, FunctionModuleRepository fmRepo,
         RfcCallRepository callRepo, TidRepository tidRepo,
         RfcQueueRepository queueRepo) {
        _destRepo   = destRepo;
        _fmRepo     = fmRepo;
        _callRepo   = callRepo;
        _tidRepo    = tidRepo;
        _queueRepo  = queueRepo;
        _executor   = RfcExecutor();
        _tidManager = TidManager(tidRepo);
    }

    InvokeRfcResponse invoke(InvokeRfcRequest req) @trusted {
        import core.time : MonoTime;

        // Validate destination
        auto dest = _destRepo.findById(req.tenantId, req.destinationId);
        if (dest.isNull())
            return _fail("Destination not found: " ~ req.destinationId);

        // Validate function module
        auto fm = _fmRepo.findById(req.tenantId, req.functionModule);
        if (fm.isNull())
            return _fail("Function module not found: " ~ req.functionModule);

        // Build call record
        auto call = RfcCall.create(req.tenantId, req.destinationId, req.functionModule, req.rfcType);

        // Copy mutable params (cannot append const to mutable array)
        foreach (p; req.importParams)  call.importParams  ~= ParameterValue(p.name, p.value);
        foreach (p; req.changingParams) call.changingParams ~= ParameterValue(p.name, p.value);

        // Allocate TID for transactional variants
        if (req.rfcType == RfcType.tRFC || req.rfcType == RfcType.qRFC || req.rfcType == RfcType.bgRFC) {
            auto tid = _tidManager.createTid(req.tenantId, req.destinationId);
            call.tid = tid.value;
        }

        // Set queue name for qRFC / bgRFC
        if (req.rfcType == RfcType.qRFC || req.rfcType == RfcType.bgRFC)
            call.queueName = req.queueName;

        call.executedAt = MonoTime.currTime.ticks;
        call.status     = RfcStatus.executing;
        _callRepo.save(call);

        // For qRFC: enqueue and return without executing
        if (req.rfcType == RfcType.qRFC) {
            import std.algorithm : count;
            auto existing = _queueRepo.findByQueue(req.tenantId, req.queueName);
            int seq = cast(int) existing.length;
            auto entry = RfcQueueEntry.create(req.tenantId, req.queueName,
                                              QueueDirection.outbound, call.tid, call.id, seq);
            _queueRepo.save(entry);

            call.status = RfcStatus.queued;
            _callRepo.update(call);

            InvokeRfcResponse resp;
            resp.success = true;
            resp.callId  = call.id;
            resp.tid     = call.tid;
            resp.status  = call.status;
            return resp;
        }

        // Execute via domain service
        auto result = _executor.execute(call, dest, fm);

        if (result.success) {
            call.status = RfcStatus.succeeded;
            foreach (p; result.exportParams)  call.exportParams  ~= ParameterValue(p.name, p.value);
            foreach (p; result.changingParams) call.changingParams ~= ParameterValue(p.name, p.value);
        } else {
            call.status       = RfcStatus.failed;
            call.errorMessage = result.errorMessage;
        }

        call.completedAt = MonoTime.currTime.ticks;
        _callRepo.update(call);

        // Commit or rollback TID
        if (call.tid.length > 0) {
            if (result.success) _tidManager.commit(req.tenantId, call.tid);
            else                _tidManager.rollback(req.tenantId, call.tid);
        }

        InvokeRfcResponse resp;
        resp.success       = result.success;
        resp.callId        = call.id;
        resp.tid           = call.tid;
        resp.status        = call.status;
        resp.error         = call.errorMessage;
        foreach (p; call.exportParams)  resp.exportParams  ~= ParameterValue(p.name, p.value);
        foreach (p; call.changingParams) resp.changingParams ~= ParameterValue(p.name, p.value);
        return resp;
    }

private:
    InvokeRfcResponse _fail(string msg) {
        InvokeRfcResponse r;
        r.success = false;
        r.error   = msg;
        r.status  = RfcStatus.failed;
        return r;
    }
}
