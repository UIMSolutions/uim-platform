/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.artifacts;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.artifact;

interface ArtifactRepository {
    Artifact findById(ArtifactId id);
    Artifact[] findAll();
    Artifact[] findByType(ArtifactType type);
    Artifact[] findByCategory(string category);
    void save(Artifact a);
    void update(Artifact a);
    void remove(ArtifactId id);
    size_t countAll();
}
