/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.services.studio_validator;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

struct StudioValidator {
    static bool isValidDevSpace(DevSpace ds) {
        return ds.name.length > 0 && ds.tenantId.value.length > 0 && ds.devSpaceTypeId.value.length > 0;
    }

    static bool isValidDevSpaceType(DevSpaceType dst) {
        return dst.name.length > 0 && dst.tenantId.value.length > 0;
    }

    static bool isValidExtension(Extension ext) {
        return ext.name.length > 0 && ext.tenantId.value.length > 0;
    }

    static bool isValidProject(Project p) {
        return p.name.length > 0 && p.tenantId.value.length > 0 && p.devSpaceId.value.length > 0;
    }

    static bool isValidProjectTemplate(ProjectTemplate pt) {
        return pt.name.length > 0 && pt.tenantId.value.length > 0;
    }

    static bool isValidServiceBinding(ServiceBinding sb) {
        return sb.name.length > 0 && sb.tenantId.value.length > 0 && sb.devSpaceId.value.length > 0;
    }

    static bool isValidRunConfiguration(RunConfiguration rc) {
        return rc.name.length > 0 && rc.tenantId.value.length > 0 && rc.projectId.value.length > 0;
    }

    static bool isValidBuildConfiguration(BuildConfiguration bc) {
        return bc.name.length > 0 && bc.tenantId.value.length > 0 && bc.projectId.value.length > 0;
    }
}
