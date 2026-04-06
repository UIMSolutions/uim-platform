/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.services.asset_validator;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct AssetValidator {
    static bool isValidEquipment(Equipment e) {
        return e.name.length > 0 && e.serialNumber.length > 0 && e.tenantId.length > 0;
    }

    static bool isValidModel(Model m) {
        return m.name.length > 0 && m.manufacturer.length > 0 && m.tenantId.length > 0;
    }

    static bool isValidCompanyProfile(CompanyProfile cp) {
        return cp.name.length > 0 && cp.contactEmail.length > 0 && cp.tenantId.length > 0;
    }

    static bool isValidDocument(Document d) {
        return d.name.length > 0 && d.tenantId.length > 0 && (d.equipmentId.length > 0 || d.modelId.length > 0);
    }

    static bool isValidAnnouncement(Announcement a) {
        return a.title.length > 0 && a.description.length > 0 && a.tenantId.length > 0;
    }

    static bool isValidFailureMode(FailureMode fm) {
        return fm.name.length > 0 && fm.modelId.length > 0 && fm.tenantId.length > 0;
    }

    static bool isValidSparePart(SparePart sp) {
        return sp.name.length > 0 && sp.partNumber.length > 0 && sp.tenantId.length > 0;
    }

    static bool isValidIndicator(Indicator ind) {
        return ind.name.length > 0 && ind.equipmentId.length > 0 && ind.tenantId.length > 0;
    }
}
