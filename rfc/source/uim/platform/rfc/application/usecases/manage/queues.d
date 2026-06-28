/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.application.usecases.manage.queues;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

class ManageQueuesUseCase {

    private RfcQueueRepository  _queueRepo;
    private RfcCallRepository   _callRepo;
    private DestinationRepository _destRepo;
    private FunctionModuleRepository _fmRepo;
    private TidRepository        _tidRepo;
    private QueueProcessor       _processor;

    this(RfcQueueRepository queueRepo, RfcCallRepository callRepo,
         DestinationRepository destRepo, FunctionModuleRepository fmRepo,
         TidRepository tidRepo) {
        _queueRepo = queueRepo;
        _callRepo  = callRepo;
        _destRepo  = destRepo;
        _fmRepo    = fmRepo;
        _tidRepo   = tidRepo;
        auto tidMgr = TidManager(tidRepo);
        _processor = QueueProcessor(queueRepo, callRepo, destRepo, fmRepo, tidMgr);
    }

    RfcQueueEntry[] listQueue(TenantId tenantId, QueueName queueName) {
        return _queueRepo.findByQueue(tenantId, queueName);
    }

    RfcQueueEntry[] listPending(TenantId tenantId, QueueName queueName) {
        return _queueRepo.findPending(tenantId, queueName);
    }

    ProcessQueueResponse processQueue(ProcessQueueRequest req) @trusted {
        import std.exception : collectException;
        ProcessQueueResponse resp;
        try {
            resp.processed = _processor.processQueue(req.tenantId, req.queueName);
            resp.success   = true;
        } catch (Exception e) {
            resp.success = false;
            resp.error   = e.msg;
        }
        return resp;
    }

    CommandResult deleteQueueEntry(TenantId tenantId, string id) {
        auto entry = _queueRepo.find(tenantId, id);
        if (entry.isNull())
            return CommandResult(false, id, "Queue entry not found: " ~ id);
        if (!_queueRepo.remove(tenantId, id))
            return CommandResult(false, id, "Failed to delete queue entry");
        return CommandResult(true, id, "");
    }

    size_t countEntries(TenantId tenantId, QueueName queueName) {
        return _queueRepo.countByQueue(tenantId, queueName);
    }
}
