module uim.platform.connectivity.application.usecases.manage_entitlements;

import uim.platform.connectivity.application.dto;
import uim.platform.management.domain.entities.entitlement;
import uim.platform.management.domain.ports.entitlement_repository;
import uim.platform.management.domain.services.entitlement_evaluator;
import uim.platform.management.domain.types;

/// Use case: manage service plan entitlements and quota assignments.
class ManageEntitlementsUseCase {
    private EntitlementRepository repo;
    private EntitlementEvaluator evaluator;

    this(EntitlementRepository repo, EntitlementEvaluator evaluator) {
        this.repo = repo;
        this.evaluator = evaluator;
    }

    CommandResult assign(AssignEntitlementRequest req) {
        if (req.globalAccountId.length == 0)
            return CommandResult(false, "", "Global account ID is required");
        if (req.servicePlanId.length == 0)
            return CommandResult(false, "", "Service plan ID is required");
        if (req.serviceName.length == 0)
            return CommandResult(false, "", "Service name is required");

        // Check current quota usage for this plan in the global account
        auto existing = repo.findByServicePlan(req.globalAccountId, req.servicePlanId);
        int currentlyAssigned = 0;
        foreach (ref e; existing)
            currentlyAssigned += e.quotaAssigned;

        import std.uuid : randomUUID;

        auto id = randomUUID().toString();

        Entitlement ent;
        ent.id = id;
        ent.globalAccountId = req.globalAccountId;
        ent.directoryId = req.directoryId;
        ent.subaccountId = req.subaccountId;
        ent.servicePlanId = req.servicePlanId;
        ent.serviceName = req.serviceName;
        ent.planName = req.planName;
        ent.quotaAssigned = req.quotaAssigned;
        ent.quotaRemaining = req.quotaAssigned;
        ent.unlimited = req.unlimited;
        ent.autoAssign = req.autoAssign;
        ent.status = EntitlementStatus.active;
        ent.assignedAt = clockSeconds();
        ent.modifiedAt = ent.assignedAt;
        ent.assignedBy = req.assignedBy;

        repo.save(ent);
        return CommandResult(true, id, "");
    }

    CommandResult updateQuota(EntitlementId id, UpdateEntitlementQuotaRequest req) {
        auto ent = repo.findById(id);
        if (ent.id.length == 0)
            return CommandResult(false, "", "Entitlement not found");

        ent.quotaAssigned = req.quotaAssigned;
        ent.unlimited = req.unlimited;
        ent.quotaRemaining = evaluator.calculateRemaining(req.quotaAssigned, ent.quotaUsed);
        ent.modifiedAt = clockSeconds();
        repo.update(ent);
        return CommandResult(true, id, "");
    }

    CommandResult revoke(EntitlementId id) {
        auto ent = repo.findById(id);
        if (ent.id.length == 0)
            return CommandResult(false, "", "Entitlement not found");

        ent.status = EntitlementStatus.revoked;
        ent.modifiedAt = clockSeconds();
        repo.update(ent);
        return CommandResult(true, id, "");
    }

    Entitlement getById(EntitlementId id) {
        return repo.findById(id);
    }

    Entitlement[] listByGlobalAccount(GlobalAccountId gaId) {
        return repo.findByGlobalAccount(gaId);
    }

    Entitlement[] listBySubaccount(SubaccountId subId) {
        return repo.findBySubaccount(subId);
    }

    Entitlement[] listByDirectory(DirectoryId dirId) {
        return repo.findByDirectory(dirId);
    }

    CommandResult remove(EntitlementId id) {
        auto ent = repo.findById(id);
        if (ent.id.length == 0)
            return CommandResult(false, "", "Entitlement not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }

    private long clockSeconds() {
        import core.time : MonoTime;

        return MonoTime.currTime.ticks / 10_000_000;
    }
}
