module uim.platform.architecture.domain.entities.solution_block;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct SolutionBlock {
    mixin TenantEntity!(SolutionBlockId);

    string name;
    string description;
    string owner;
    LifecycleStatus status;
    string versionLabel;
    string[] tags;
    string mappedAbbId; // Referenz auf das abgedeckte ABB
    string vendorOrComponent; // z.B. "PostgreSQL 15" oder "Internal Auth Microservice"
    string deploymentEndpoint;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("owner", owner)
            .set("status", status.toString)
            .set("versionLabel", versionLabel)
            .set("tags", tags.toJson)
            .set("mappedAbbId", mappedAbbId)
            .set("vendorOrComponent", vendorOrComponent)
            .set("deploymentEndpoint", deploymentEndpoint);
    }
}
