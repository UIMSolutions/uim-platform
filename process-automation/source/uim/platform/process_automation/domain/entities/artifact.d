/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.artifact;

import uim.platform.process_automation.domain.types;

struct ArtifactDependency {
    string artifactId;
    string minVersion;
}

struct Artifact {
    ArtifactId id;
    string name;
    string description;
    ArtifactType type;
    ArtifactStatus status;
    string version_;
    string author;
    string category;
    string[] tags;
    ArtifactDependency[] dependencies;
    string contentUrl;
    long downloadCount;
    double rating;
    long publishedAt;
    long updatedAt;
}
