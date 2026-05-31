/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.customer;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class CustomerController : ManageController {
    private ManageCustomersUseCase customers;

    this(ManageCustomersUseCase customers) {
        this.customers = customers;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/customers", &handleList);
        router.get("/api/v1/customer-identity/customers/*", &handleGet);
        router.post("/api/v1/customer-identity/customers", &handleCreate);
        router.put("/api/v1/customer-identity/customers/*", &handleUpdate);
        router.delete_("/api/v1/customer-identity/customers/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = customers.listCustomers(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Customers retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CustomerDTO dto;
        dto.tenantId = tenantId;
        dto.email = data.getString("email");
        dto.phone = data.getString("phone");
        dto.firstName = data.getString("firstName");
        dto.lastName = data.getString("lastName");
        dto.password = data.getString("password");
        dto.locale = data.getString("locale");
        dto.country = data.getString("country");
        dto.birthDate = data.getString("birthDate");
        dto.profileData = data.getString("profileData");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = customers.registerCustomer(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData =  Json.emptyObject.set("id", result.id);
        return successResponse("Customer created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CustomerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Customer ID", 400);

        auto e = customers.getCustomer(tenantId, id);
        if (e.isNull)
            return errorResponse("Customer not found", 404);

        return successResponse("Customer retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CustomerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Customer ID", 400);

        auto data = precheck.data;
        CustomerDTO dto;
        dto.customerId = id;
        dto.tenantId = tenantId;
        dto.firstName = data.getString("firstName");
        dto.lastName = data.getString("lastName");
        dto.phone = data.getString("phone");
        dto.locale = data.getString("locale");
        dto.country = data.getString("country");
        dto.birthDate = data.getString("birthDate");
        dto.profileData = data.getString("profileData");
        dto.progressiveData = data.getString("progressiveData");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = customers.updateCustomer(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Customer updated successfully", "Updated", 200, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CustomerId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Customer ID", 400);

        auto result = customers.deleteCustomer(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Customer deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
    }
}
