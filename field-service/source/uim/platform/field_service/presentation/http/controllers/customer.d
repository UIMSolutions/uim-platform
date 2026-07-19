/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.controllers.customer;

import uim.platform.field_service;
mixin(ShowModule!());

@safe:

class CustomerController : ManageHttpController {
    private ManageCustomersUseCase usecase;

    this(ManageCustomersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/field-service/customers", &handleList);
        router.get("/api/v1/field-service/customers/*", &handleGet);
        router.post("/api/v1/field-service/customers", &handleCreate);
        router.put("/api/v1/field-service/customers/*", &handleUpdate);
        router.delete_("/api/v1/field-service/customers/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listCustomers(tenantId);
        auto list = items.map!(e => e.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Customers retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = CustomerId(precheck.id);

        auto customer = usecase.getCustomer(tenantId, id);
        if (customer.isNull)
            return errorResponse("Customer not found", 404);

        return successResponse("Customer retrieved successfully", "Retrieved", 200, customer.toJson);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CustomerDTO dto;
        dto.customerId = CustomerId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.customerType = data.getString("customerType");
        dto.contactPerson = data.getString("contactPerson");
        dto.email = data.getString("email");
        dto.phone = data.getString("phone");
        dto.address = data.getString("address");
        dto.latitude = data.getString("latitude");
        dto.longitude = data.getString("longitude");
        dto.website = data.getString("website");
        dto.industry = data.getString("industry");
        dto.accountNumber = data.getString("accountNumber");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createCustomer(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Customer created successfully", "Created", 201, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto data = precheck.data;
        CustomerDTO dto;
        dto.customerId = CustomerId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.contactPerson = data.getString("contactPerson");
        dto.email = data.getString("email");
        dto.phone = data.getString("phone");
        dto.address = data.getString("address");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateCustomer(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Customer updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CustomerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid customer ID", 400);
            
        auto result = usecase.deleteCustomer(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Customer deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result
                .id));
    }
}
