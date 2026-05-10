/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.services.masterdata_governance_validator;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

struct MasterdataGovernanceValidator {
    static bool isValidBusinessPartner(BusinessPartner bp) {
        if (bp.tenantId.isNull) return false;
        if (bp.category == BPCategory.person)
            return bp.firstName.length > 0 || bp.lastName.length > 0;
        return bp.organizationName.length > 0;
    }

    static bool isValidChangeRequest(ChangeRequest cr) {
        return !cr.tenantId.isNull
            && !cr.businessPartnerId.isNull
            && cr.subject.length > 0;
    }

    static bool isValidDataQualityRule(DataQualityRule rule) {
        return !rule.tenantId.isNull
            && rule.name.length > 0
            && rule.fieldName.length > 0;
    }

    static bool isValidDataQualityScore(DataQualityScore score) {
        return !score.tenantId.isNull
            && !score.businessPartnerId.isNull
            && score.overallScore >= 0
            && score.overallScore <= 100;
    }

    static bool isValidReplication(Replication rep) {
        return !rep.tenantId.isNull
            && !rep.businessPartnerId.isNull
            && rep.targetSystem.length > 0;
    }
}
