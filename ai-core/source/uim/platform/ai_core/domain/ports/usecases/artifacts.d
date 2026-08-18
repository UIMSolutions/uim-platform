/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.usecases.artifacts;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface IManageArtifactsUseCase { 

  UsecaseResult createArtifact(CreateArtifactRequest r);
  Artifact getArtifact(TenantId tenantId, ResourceGroupId resourceGroupId, ArtifactId artifactId);
  Artifact[] listArtifacts(TenantId tenantId, ResourceGroupId resourceGroupId);
  Artifact[] listArtifacts(TenantId tenantId, ResourceGroupId resourceGroupId, ScenarioId scenarioId);
  Artifact[] listArtifacts(TenantId tenantId, ResourceGroupId resourceGroupId, ArtifactKind kind);
  Artifact[] listArtifacts(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionId executionId);
  UsecaseResult deleteArtifact(TenantId tenantId, ResourceGroupId resourceGroupId, ArtifactId artifactId);

}
