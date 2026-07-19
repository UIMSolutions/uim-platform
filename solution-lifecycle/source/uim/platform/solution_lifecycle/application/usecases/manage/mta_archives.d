/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.application.usecases.manage.mta_archives;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

class ManageMtaArchivesUseCase {
    private MtaArchiveRepository repo;

    this(MtaArchiveRepository repo) {
        this.repo = repo;
    }

    CommandResult uploadArchive(UploadMtaArchiveRequest r) {
        
        

        auto err = (new DeploymentEngine()).validateArchive(r.mtaId, r.mtaVersion, r.targetPlatforms);
        if (err.length > 0) return CommandResult(false, "", err);

        auto archive = new MtaArchive();
        archive.id           = MtaArchiveId(MonoTime.currTime.ticks.to!string);
        archive.tenantId     = r.tenantId;
        archive.fileName     = r.fileName;
        archive.mtaId        = r.mtaId;
        archive.mtaVersion   = r.mtaVersion;
        archive.fileSizeBytes = r.fileSizeBytes;
        archive.checksum     = r.checksum;
        archive.uploadedBy   = r.uploadedBy;
        archive.namespace_   = r.namespace_;
        archive.targetPlatforms = r.targetPlatforms;
        archive.validated    = true;
        archive.createdAt    = MonoTime.currTime.ticks;
        archive.updatedAt    = archive.createdAt;

        repo.save(archive);
        return CommandResult(true, archive.id.value, "");
    }

    MtaArchive[] listArchives(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    MtaArchive getArchive(TenantId tenantId, MtaArchiveId id) {
        auto results = repo.findByTenant(tenantId);
        foreach (a; results)
            if (a.id.value == id.value) return a;
        return new MtaArchive();
    }

    CommandResult deleteArchive(TenantId tenantId, MtaArchiveId id) {
        auto a = getArchive(tenantId, id);
        if (a.isNull) return CommandResult(false, "", "MTA archive not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
