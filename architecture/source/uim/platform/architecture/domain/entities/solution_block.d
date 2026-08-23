module uim.platform.architecture.domain.entities.solution_block;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct SolutionBlock {
    mixin TenantEntity!(SolutionBlockId);

    string title;
    string description;
    string owner;
    LifecycleStatus status;
    string versionLabel;
    string[] tags;
    string mappedAbbId; // Referenz auf das abgedeckte ABB
    string vendorOrComponent; // z.B. "PostgreSQL 15" oder "Internal Auth Microservice"
    string deploymentEndpoint;
    LeanIXSolutionObjectType leanixObjectType;
    string leanixFactSheetId;
    string providerApplicationId;
    string consumerApplicationId;
    ArchiMateDomain archimateDomain;
    ArchiMateAspect archimateAspect;
    string viewpoint;
    ArchiMateRelationship[] relationships;

    Json toJson() const {
        return entityToJson
            .set("title", title)
            .set("description", description)
            .set("owner", owner)
            .set("status", status.toString)
            .set("versionLabel", versionLabel)
            .set("tags", tags.toJson)
            .set("mappedAbbId", mappedAbbId)
            .set("vendorOrComponent", vendorOrComponent)
            .set("deploymentEndpoint", deploymentEndpoint)
            .set("leanixObjectType", leanixObjectType.toString)
            .set("leanixFactSheetId", leanixFactSheetId)
            .set("providerApplicationId", providerApplicationId)
            .set("consumerApplicationId", consumerApplicationId)
            .set("archimateDomain", archimateDomain.toString)
            .set("archimateAspect", archimateAspect.toString)
            .set("viewpoint", viewpoint)
            .set("relationships", relationships.toJson);
    }
}
