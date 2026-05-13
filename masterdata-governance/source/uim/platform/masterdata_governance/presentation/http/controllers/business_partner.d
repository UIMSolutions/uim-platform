/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.business_partner;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class BusinessPartnerController : PlatformController {
    private ManageBusinessPartnersUseCase usecase;

    this(ManageBusinessPartnersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/masterdata-governance/business-partners", &handleList);
        router.get("/api/v1/masterdata-governance/business-partners/*", &handleGet);
        router.post("/api/v1/masterdata-governance/business-partners", &handleCreate);
        router.put("/api/v1/masterdata-governance/business-partners/*", &handleUpdate);
        router.delete_("/api/v1/masterdata-governance/business-partners/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listBusinessPartners(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BusinessPartnerId(extractIdFromPath(path));
            auto bp = usecase.getBusinessPartner(tenantId, id);
            if (bp.isNull) { writeError(res, 404, "Business partner not found"); return; }
            res.writeJsonBody(bp.toJson, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            BusinessPartnerDTO dto;
            dto.businessPartnerId = BusinessPartnerId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.bpNumber = j.getString("bpNumber");
            dto.firstName = j.getString("firstName");
            dto.lastName = j.getString("lastName");
            dto.title = j.getString("title");
            dto.gender = j.getString("gender");
            dto.dateOfBirth = j.getString("dateOfBirth");
            dto.nationality = j.getString("nationality");
            dto.organizationName = j.getString("organizationName");
            dto.organizationNameAdditional = j.getString("organizationNameAdditional");
            dto.industryCode = j.getString("industryCode");
            dto.industryDescription = j.getString("industryDescription");
            dto.email = j.getString("email");
            dto.phone = j.getString("phone");
            dto.mobile = j.getString("mobile");
            dto.fax = j.getString("fax");
            dto.website = j.getString("website");
            dto.street = j.getString("street");
            dto.houseNumber = j.getString("houseNumber");
            dto.postalCode = j.getString("postalCode");
            dto.city = j.getString("city");
            dto.region = j.getString("region");
            dto.country = j.getString("country");
            dto.addressType = j.getString("addressType");
            dto.taxNumber = j.getString("taxNumber");
            dto.vatNumber = j.getString("vatNumber");
            dto.taxJurisdiction = j.getString("taxJurisdiction");
            dto.roles = j.getString("roles");
            dto.bankAccountNumber = j.getString("bankAccountNumber");
            dto.bankRoutingNumber = j.getString("bankRoutingNumber");
            dto.bankName = j.getString("bankName");
            dto.bankCountry = j.getString("bankCountry");
            dto.externalBpId = j.getString("externalBpId");
            dto.sourceSystem = j.getString("sourceSystem");
            dto.searchTerms = j.getString("searchTerms");
            dto.language = j.getString("language");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createBusinessPartner(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Business partner created"), 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            BusinessPartnerDTO dto;
            dto.businessPartnerId = BusinessPartnerId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.firstName = j.getString("firstName");
            dto.lastName = j.getString("lastName");
            dto.title = j.getString("title");
            dto.organizationName = j.getString("organizationName");
            dto.industryCode = j.getString("industryCode");
            dto.email = j.getString("email");
            dto.phone = j.getString("phone");
            dto.mobile = j.getString("mobile");
            dto.website = j.getString("website");
            dto.street = j.getString("street");
            dto.postalCode = j.getString("postalCode");
            dto.city = j.getString("city");
            dto.country = j.getString("country");
            dto.taxNumber = j.getString("taxNumber");
            dto.vatNumber = j.getString("vatNumber");
            dto.roles = j.getString("roles");
            dto.searchTerms = j.getString("searchTerms");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateBusinessPartner(dto);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Business partner updated"), 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BusinessPartnerId(extractIdFromPath(path));
            auto result = usecase.deleteBusinessPartner(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("message", "Business partner deleted"), 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
