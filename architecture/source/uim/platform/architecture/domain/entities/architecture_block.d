module uim.platform.architecture.domain.entities.architecture_block;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct ArchiMateRelationship {
    ArchiMateRelationshipType relationshipType;
    string targetBlockId;
    string description;

    Json toJson() const {
        return Json.emptyObject
            .set("relationshipType", relationshipType.toString)
            .set("targetBlockId", targetBlockId)
            .set("description", description);
    }
}

struct ArchitectureBlock {
    mixin TenantEntity!(ArchitectureBlockId);

    string title;
    string description;
    string owner;
    string lifecycleState;
    string versionLabel;
    bool lastVersion;
    long validDate;
    string[] tags;
    string capabilityProvided;
    string[] requiredInterfaces;
    ArchiMateDomain archimateDomain;
    ArchiMateAspect archimateAspect;
    string viewpoint;
    ArchiMateRelationship[] relationships;
    LifecycleStatus status;

    Json toJson() const {
        auto tagsJson = tags.toJson;
        return entityToJson
            .set("title", title)
            .set("description", description)
            .set("owner", owner)
            .set("lifecycleState", lifecycleState)
            .set("status", status.toString)
            .set("versionLabel", versionLabel)
            .set("tags", tagsJson)
            .set("capabilityProvided", capabilityProvided)
            .set("requiredInterfaces", requiredInterfaces.toJson)
            .set("archimateDomain", archimateDomain.toString)
            .set("archimateAspect", archimateAspect.toString)
            .set("viewpoint", viewpoint)
            .set("relationships", relationships.toJson)
            .set("lastVersion", lastVersion)
            .set("validDate", validDate);
    }
}
