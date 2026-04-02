module application.usecases.manage_environment_instances;

import application.dto;
import uim.platform.management.domain.entities.environment_instance;
import uim.platform.management.domain.entities.subaccount;
import uim.platform.management.domain.ports.environment_instance_repository;
import uim.platform.management.domain.ports.subaccount_repository;
import uim.platform.management.domain.services.environment_provisioner;
import uim.platform.management.domain.types;

/// Use case: manage environment instance lifecycle (CF, Kyma, ABAP).
class ManageEnvironmentInstancesUseCase {
    private EnvironmentInstanceRepository repo;
    private SubaccountRepository subaccountRepo;
    private EnvironmentProvisioner provisioner;

    this(EnvironmentInstanceRepository repo, SubaccountRepository subaccountRepo,
        EnvironmentProvisioner provisioner) {
        this.repo = repo;
        this.subaccountRepo = subaccountRepo;
        this.provisioner = provisioner;
    }

    CommandResult create(CreateEnvironmentInstanceRequest req) {
        if (req.subaccountId.length == 0)
            return CommandResult(false, "", "Subaccount ID is required");
        if (req.name.length == 0)
            return CommandResult(false, "", "Environment name is required");

        auto subaccount = subaccountRepo.findById(req.subaccountId);
        if (subaccount.id.length == 0)
            return CommandResult(false, "", "Subaccount not found");

        auto envType = parseEnvironmentType(req.environmentType);
        auto existing = repo.findBySubaccount(req.subaccountId);

        auto validation = provisioner.validateProvisioning(envType, req.planName, subaccount, existing);
        if (!validation.valid)
            return CommandResult(false, "", validation.reason);

        import std.uuid : randomUUID;

        auto id = randomUUID().toString();

        EnvironmentInstance inst;
        inst.id = id;
        inst.subaccountId = req.subaccountId;
        inst.globalAccountId = req.globalAccountId;
        inst.name = req.name;
        inst.description = req.description;
        inst.environmentType = envType;
        inst.planName = req.planName;
        inst.landscapeLabel = req.landscapeLabel;
        inst.status = EnvironmentStatus.creating;
        inst.memoryQuotaMb = req.memoryQuotaMb;
        inst.routeQuota = req.routeQuota;
        inst.serviceQuota = req.serviceQuota;
        inst.createdBy = req.createdBy;
        inst.createdAt = clockSeconds();
        inst.modifiedAt = inst.createdAt;
        inst.parameters = req.parameters;
        inst.labels = req.labels;

        repo.save(inst);

        // Transition to active (simulated provisioning)
        inst.status = EnvironmentStatus.active;
        inst.dashboardUrl = "/environments/" ~ id ~ "/dashboard";
        inst.technicalKey = "env-" ~ id[0 .. 8];
        repo.update(inst);

        return CommandResult(true, id, "");
    }

    CommandResult update(EnvironmentInstanceId id, UpdateEnvironmentInstanceRequest req) {
        auto inst = repo.findById(id);
        if (inst.id.length == 0)
            return CommandResult(false, "", "Environment instance not found");

        if (req.description.length > 0)
            inst.description = req.description;
        if (req.memoryQuotaMb > 0)
            inst.memoryQuotaMb = req.memoryQuotaMb;
        if (req.routeQuota > 0)
            inst.routeQuota = req.routeQuota;
        if (req.serviceQuota > 0)
            inst.serviceQuota = req.serviceQuota;
        if (req.parameters.length > 0)
            inst.parameters = req.parameters;
        if (req.labels.length > 0)
            inst.labels = req.labels;
        inst.modifiedAt = clockSeconds();

        repo.update(inst);
        return CommandResult(true, id, "");
    }

    CommandResult deprovision(EnvironmentInstanceId id) {
        auto inst = repo.findById(id);
        if (inst.id.length == 0)
            return CommandResult(false, "", "Environment instance not found");
        if (!provisioner.canDelete(inst))
            return CommandResult(false, "", "Environment cannot be deleted in current status");

        inst.status = EnvironmentStatus.deleting;
        inst.modifiedAt = clockSeconds();
        repo.update(inst);

        // Complete deletion
        repo.remove(id);
        return CommandResult(true, id, "");
    }

    EnvironmentInstance getById(EnvironmentInstanceId id) {
        return repo.findById(id);
    }

    EnvironmentInstance[] listBySubaccount(SubaccountId subId) {
        return repo.findBySubaccount(subId);
    }

    EnvironmentInstance[] listByType(SubaccountId subId, string envType) {
        return repo.findByType(subId, parseEnvironmentType(envType));
    }

    private EnvironmentType parseEnvironmentType(string s) {
        switch (s) {
        case "cloudFoundry":
            return EnvironmentType.cloudFoundry;
        case "kyma":
            return EnvironmentType.kyma;
        case "abap":
            return EnvironmentType.abap;
        case "neo":
            return EnvironmentType.neo;
        default:
            return EnvironmentType.cloudFoundry;
        }
    }

    private long clockSeconds() {
        import core.time : MonoTime;

        return MonoTime.currTime.ticks / 10_000_000;
    }
}
