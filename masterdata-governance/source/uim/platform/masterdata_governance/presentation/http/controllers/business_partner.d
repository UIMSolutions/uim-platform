/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.presentation.http.controllers.business_partner;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class BusinessPartnerController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listBusinessPartners(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;
        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Business partner list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BusinessPartnerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid business partner ID", 400);

        auto bp = usecase.getBusinessPartner(tenantId, id);
        if (bp.isNull)
            return errorResponse("Business partner not found", 404);
        
        auto responseData = bp.toJson();
        return successResponse("Business partner retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        BusinessPartnerDTO dto;
        dto.tenantId = tenantId;
        dto.bpNumber = data.getString("bpNumber");
        dto.firstName = data.getString(
            "firstName");
        dto.lastName = data.getString("lastName");
        dto.title = data.getString(
            "title");
        dto.gender = data.getString("gender");
        dto.dateOfBirth = data.getString(
            "dateOfBirth");
        dto.nationality = data.getString("nationality");
        dto.organizationName = data.getString("organizationName");
        dto.organizationNameAdditional = data
            .getString("organizationNameAdditional");
        dto.industryCode = data.getString(
            "industryCode");
        dto.industryDescription = data.getString(
            "industryDescription");
        dto.email = data.getString("email");
        dto.phone = data.getString(
            "phone");
        dto.mobile = data.getString("mobile");
        dto.fax = data.getString(
            "fax");
        dto.website = data.getString("website");
        dto.street = data.getString(
            "street");
        dto.houseNumber = data.getString("houseNumber");
        dto.postalCode = data.getString(
            "postalCode");
        dto.city = data.getString("city");
        dto.region = data.getString(
            "region");
        dto.country = data.getString("country");
        dto.addressType = data.getString(
            "addressType");
        dto.taxNumber = data.getString("taxNumber");
        dto.vatNumber = data.getString(
            "vatNumber");
        dto.taxJurisdiction = data.getString("taxJurisdiction");
        dto.roles = data.getString("roles");
        dto.bankAccountNumber = data.getString(
            "bankAccountNumber");
        dto.bankRoutingNumber = data.getString(
            "bankRoutingNumber");
        dto.bankName = data.getString("bankName");
        dto.bankCountry = data.getString("bankCountry");
        dto.externalBpId = data.getString(
            "externalBpId");
        dto.sourceSystem = data.getString("sourceSystem");
        dto.searchTerms = data.getString("searchTerms");
        dto.language = data.getString(
            "language");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createBusinessPartner(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Business partner created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BusinessPartnerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid business partner ID", 400);

        auto data = precheck.data;
        BusinessPartnerDTO dto;
        dto.businessPartnerId = id;
        dto.tenantId = tenantId;
        dto.firstName = data.getString(
            "firstName");
        dto.lastName = data.getString("lastName");
        dto.title = data.getString("title");
        dto.organizationName = data.getString(
            "organizationName");
        dto.industryCode = data.getString("industryCode");
        dto.email = data.getString("email");
        dto.phone = data.getString("phone");
        dto.mobile = data.getString("mobile");
        dto.website = data.getString(
            "website");
        dto.street = data.getString("street");
        dto.postalCode = data.getString(
            "postalCode");
        dto.city = data.getString("city");
        dto.country = data.getString(
            "country");
        dto.taxNumber = data.getString("taxNumber");
        dto.vatNumber = data.getString("vatNumber");
        dto.roles = data.getString(
            "roles");
        dto.searchTerms = data.getString("searchTerms");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase
            .updateBusinessPartner(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Business partner updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BusinessPartnerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid scan job ID", 400);

        auto result = usecase.deleteBusinessPartner(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Business partner deleted successfully", "Deleted", 200, responseData);
    }
}
