/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.services.product_validator;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct ProductValidator {
    static bool isValidProduct(Product p) {
        return p.name.length > 0 && p.tenantId.length > 0;
    }

    static bool isValidBom(BillOfMaterial b) {
        return b.name.length > 0 && b.tenantId.length > 0 && b.productId.length > 0;
    }

    static bool isValidChangeRequest(ChangeRequest cr) {
        return cr.title.length > 0 && cr.tenantId.length > 0 && cr.reason.length > 0;
    }

    static bool isValidDocument(Document d) {
        return d.name.length > 0 && d.tenantId.length > 0;
    }

    static bool isValidSpecification(Specification s) {
        return s.name.length > 0 && s.tenantId.length > 0 && s.property.length > 0;
    }

    static bool isValidRecipe(Recipe r) {
        return r.name.length > 0 && r.tenantId.length > 0 && r.productId.length > 0;
    }

    static bool isValidCollaboration(Collaboration c) {
        return c.title.length > 0 && c.tenantId.length > 0;
    }

    static bool isValidProductStructure(ProductStructure ps) {
        return ps.name.length > 0 && ps.tenantId.length > 0 && ps.productId.length > 0;
    }
}
