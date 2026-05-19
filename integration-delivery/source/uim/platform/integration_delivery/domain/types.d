/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.types;

import uim.platform.integration_delivery;

mixin(ShowModule!());

@safe:

struct CicdRepositoryId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct CredentialId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct PipelineId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct JobId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct BuildId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct StageId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct WebhookId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct DeploymentTargetId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}
