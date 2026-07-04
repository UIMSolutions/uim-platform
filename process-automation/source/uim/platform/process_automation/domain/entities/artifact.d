/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.artifact;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

struct ArtifactDependency {
    ArtifactId artifactId;
    string minVersion;

    Json toJson() const {
        return Json()
            .set("artifactId", artifactId.value)
            .set("minVersion", minVersion);
    }
}

struct Artifact {
    mixin TenantEntity!ArtifactId;

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

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("type", type.to!string())
            .set("status", status.to!string())
            .set("version", version_)
            .set("author", author)
            .set("category", category)
            .set("tags", tags.toJson)
            .set("dependencies", dependencies.map!(d => d.toJson()).array.toJson)
            .set("contentUrl", contentUrl)
            .set("downloadCount", downloadCount)
            .set("rating", rating)
            .set("publishedAt", publishedAt);
    }


}
