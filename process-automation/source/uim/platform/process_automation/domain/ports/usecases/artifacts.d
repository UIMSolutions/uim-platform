/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.artifacts;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageArtifactsUseCase { 
    
    UsecaseResult createArtifact(CreateArtifactRequest r);
    Artifact getArtifact(TenantId tenantId, ArtifactId id);
    Artifact[] listArtifacts(TenantId tenantId);
    Artifact[] listArtifacts(TenantId tenantId, ArtifactType type);
    UsecaseResult updateArtifact(UpdateArtifactRequest r);
    UsecaseResult deleteArtifact(TenantId tenantId, ArtifactId id);

}
