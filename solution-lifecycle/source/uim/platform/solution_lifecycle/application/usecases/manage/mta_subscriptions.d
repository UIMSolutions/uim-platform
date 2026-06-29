/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.application.usecases.manage.mta_subscriptions;

import uim.platform.solution_lifecycle;

// mixin(ShowModule!());

@safe:

class ManageMtaSubscriptionsUseCase {
    private MtaSubscriptionRepository repo;
    private MtaOperationRepository     opRepo;
    private DeploymentEngine           engine;

    this(MtaSubscriptionRepository repo, MtaOperationRepository opRepo, DeploymentEngine engine) {
        this.repo   = repo;
        this.opRepo = opRepo;
        this.engine = engine;
    }

    MtaSubscription[] listSubscriptions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    MtaSubscription getSubscription(TenantId tenantId, MtaSubscriptionId id) {
        auto subs = repo.findByTenant(tenantId);
        foreach (s; subs)
            if (s.id.value == id.value) return s;
        return new MtaSubscription();
    }

    CommandResult subscribe(SubscribeMtaRequest r) {
        
        

        auto dres = engine.beginSubscribe(r.providerMtaId, r.providerTenantId, r.tenantId);
        if (!dres.success) return CommandResult(false, "", dres.message);

        auto op = new MtaOperation();
        op.id              = MtaOperationId(dres.operationId);
        op.tenantId        = r.tenantId;
        op.operationType   = OperationType.subscribe;
        op.operationStatus = OperationStatus.queued;
        op.mtaId           = r.providerMtaId;
        op.initiatedBy     = r.subscribedBy;
        op.progressPercent = 0;
        op.progressMessage = "Subscribe operation queued";
        op.startedAt       = MonoTime.currTime.ticks;
        op.createdAt       = op.startedAt;
        op.updatedAt       = op.startedAt;
        opRepo.save(op);

        auto sub = new MtaSubscription();
        sub.id                  = MtaSubscriptionId(MonoTime.currTime.ticks.to!string ~ "-sub");
        sub.tenantId            = r.tenantId;
        sub.mtaId               = r.providerMtaId;
        sub.providerTenantId    = r.providerTenantId;
        sub.providerSpaceId     = r.providerSpaceId;
        sub.subscriptionStatus  = SubscriptionStatus.subscribing;
        sub.subscribedBy        = r.subscribedBy;
        sub.extensionDescriptor = r.extensionDescriptor;
        sub.lastOperationId     = op.id.value;
        sub.subscribedAt        = MonoTime.currTime.ticks;
        sub.createdAt           = sub.subscribedAt;
        sub.updatedAt           = sub.subscribedAt;
        repo.save(sub);

        return CommandResult(true, op.id.value, "");
    }

    CommandResult unsubscribe(UnsubscribeMtaRequest r) {
        
        

        auto sub = getSubscription(r.tenantId, MtaSubscriptionId(r.subscriptionId));
        if (sub is null || sub.isNull)
            return CommandResult(false, "", "Subscription not found: " ~ r.subscriptionId);

        auto dres = engine.beginUnsubscribe(r.subscriptionId, r.tenantId);
        auto op = new MtaOperation();
        op.id              = MtaOperationId(dres.operationId);
        op.tenantId        = r.tenantId;
        op.operationType   = OperationType.unsubscribe;
        op.operationStatus = OperationStatus.queued;
        op.mtaId           = sub.mtaId;
        op.initiatedBy     = r.unsubscribedBy;
        op.progressPercent = 0;
        op.progressMessage = "Unsubscribe operation queued";
        op.startedAt       = MonoTime.currTime.ticks;
        op.createdAt       = op.startedAt;
        op.updatedAt       = op.startedAt;
        opRepo.save(op);

        sub.subscriptionStatus = SubscriptionStatus.unsubscribing;
        sub.lastOperationId    = op.id.value;
        sub.unsubscribedAt     = MonoTime.currTime.ticks;
        sub.updatedAt          = sub.unsubscribedAt;
        repo.update(sub);

        return CommandResult(true, op.id.value, "");
    }
}
