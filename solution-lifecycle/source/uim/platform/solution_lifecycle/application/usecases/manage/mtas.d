/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.application.usecases.manage.mtas;

import uim.platform.solution_lifecycle;

// mixin(ShowModule!());

@safe:

class ManageMtasUseCase {
    private MtaRepository        mtaRepo;
    private MtaOperationRepository opRepo;
    private MtaArchiveRepository archiveRepo;
    private DeploymentEngine     engine;

    this(MtaRepository mtaRepo, MtaOperationRepository opRepo,
         MtaArchiveRepository archiveRepo, DeploymentEngine engine) {
        this.mtaRepo     = mtaRepo;
        this.opRepo      = opRepo;
        this.archiveRepo = archiveRepo;
        this.engine      = engine;
    }

    // ------------------------------------------------------------------
    // Deploy a new MTA from an uploaded archive
    // ------------------------------------------------------------------
    CommandResult deployMta(DeployMtaRequest r) {
        
        

        // Locate archive
        auto archives = archiveRepo.findByTenant(r.tenantId);
        MtaArchive archive;
        foreach (a; archives)
            if (a.id.value == r.archiveId) { archive = a; break; }
        if (archive is null || archive.isNull)
            return CommandResult(false, "", "MTA archive not found: " ~ r.archiveId);

        auto dres = engine.beginDeploy(r.archiveId, archive.mtaId, archive.mtaVersion, r.tenantId);
        if (!dres.success) return CommandResult(false, "", dres.message);

        // Create operation record
        auto op = new MtaOperation();
        op.id              = MtaOperationId(dres.operationId);
        op.tenantId        = r.tenantId;
        op.operationType   = OperationType.deploy;
        op.operationStatus = OperationStatus.queued;
        op.mtaId           = archive.mtaId;
        op.mtaVersion      = archive.mtaVersion;
        op.archiveId       = r.archiveId;
        op.initiatedBy     = r.deployedBy;
        op.progressPercent = 0;
        op.progressMessage = "Deploy operation queued";
        op.startedAt       = MonoTime.currTime.ticks;
        op.createdAt       = op.startedAt;
        op.updatedAt       = op.startedAt;
        opRepo.save(op);

        // Create the MTA record in deploying state
        auto solType = SolutionType.standard;
        if (r.solutionType == "provided") solType = SolutionType.provided_;
        else if (r.solutionType == "subscribed") solType = SolutionType.subscribed;

        auto mta = new Mta();
        mta.id              = MtaId(MonoTime.currTime.ticks.to!string ~ "-mta");
        mta.tenantId        = r.tenantId;
        mta.mtaId           = archive.mtaId;
        mta.version_        = archive.mtaVersion;
        mta.description     = archive.fileName;
        mta.solutionType    = solType;
        mta.status          = MtaStatus.deploying;
        mta.archiveId       = r.archiveId;
        mta.deployedBy      = r.deployedBy;
        mta.namespace_      = r.namespace_;
        mta.spaceId         = r.spaceId;
        mta.extensionDescriptor = r.extensionDescriptor;
        mta.lastOperationId = op.id.value;
        mta.createdAt       = op.startedAt;
        mta.updatedAt       = op.startedAt;
        mtaRepo.save(mta);

        return CommandResult(true, op.id.value, "");
    }

    // ------------------------------------------------------------------
    // Update an existing deployed MTA
    // ------------------------------------------------------------------
    CommandResult updateMta(UpdateMtaRequest r) {
        
        

        auto mtas = mtaRepo.findByTenant(r.tenantId);
        Mta existing;
        foreach (m; mtas)
            if (m.mtaId == r.mtaId) { existing = m; break; }
        if (existing is null || existing.isNull)
            return CommandResult(false, "", "Deployed MTA not found: " ~ r.mtaId);

        auto dres = engine.beginUpdate(r.archiveId, r.mtaId, r.tenantId);
        if (!dres.success) return CommandResult(false, "", dres.message);

        auto op = new MtaOperation();
        op.id              = MtaOperationId(dres.operationId);
        op.tenantId        = r.tenantId;
        op.operationType   = OperationType.update;
        op.operationStatus = OperationStatus.queued;
        op.mtaId           = r.mtaId;
        op.archiveId       = r.archiveId;
        op.initiatedBy     = r.updatedBy;
        op.progressPercent = 0;
        op.progressMessage = "Update operation queued";
        op.startedAt       = MonoTime.currTime.ticks;
        op.createdAt       = op.startedAt;
        op.updatedAt       = op.startedAt;
        opRepo.save(op);

        existing.status          = MtaStatus.updating;
        existing.lastOperationId = op.id.value;
        existing.archiveId       = r.archiveId;
        existing.extensionDescriptor = r.extensionDescriptor;
        existing.updatedAt       = op.startedAt;
        mtaRepo.update(existing);

        return CommandResult(true, op.id.value, "");
    }

    // ------------------------------------------------------------------
    // List / Get
    // ------------------------------------------------------------------
    Mta[] listMtas(TenantId tenantId) {
        return mtaRepo.find(tenantId);
    }

    Mta getMta(TenantId tenantId, MtaId id) {
        auto mtas = mtaRepo.find(tenantId);
        foreach (m; mtas)
            if (m.id.value == id.value) return m;
        return new Mta();
    }

    // ------------------------------------------------------------------
    // Delete (async)
    // ------------------------------------------------------------------
    CommandResult deleteMta(DeleteMtaRequest r) {
        
        

        auto mtas = mtaRepo.findByTenant(r.tenantId);
        Mta existing;
        foreach (m; mtas)
            if (m.mtaId == r.mtaId) { existing = m; break; }
        if (existing is null || existing.isNull)
            return CommandResult(false, "", "Deployed MTA not found: " ~ r.mtaId);

        auto dres = engine.beginDelete(r.mtaId, r.tenantId);
        auto op = new MtaOperation();
        op.id              = MtaOperationId(dres.operationId);
        op.tenantId        = r.tenantId;
        op.operationType   = OperationType.delete_;
        op.operationStatus = OperationStatus.queued;
        op.mtaId           = r.mtaId;
        op.initiatedBy     = r.deletedBy;
        op.progressPercent = 0;
        op.progressMessage = "Delete operation queued";
        op.startedAt       = MonoTime.currTime.ticks;
        op.createdAt       = op.startedAt;
        op.updatedAt       = op.startedAt;
        opRepo.save(op);

        existing.status          = MtaStatus.deleting;
        existing.lastOperationId = op.id.value;
        existing.updatedAt       = op.startedAt;
        mtaRepo.update(existing);

        return CommandResult(true, op.id.value, "");
    }
}
