module uim.platform.management.presentation.rest.tests.subaccount;

import uim.platform.management;

// mixin(ShowModule!());

unittest {
    import vibe.core.core : yield, runTask;

    logInfo("--- Starting Service-Unittest ---");

    // 1. Loading Configuration and Building Container
    auto config = loadConfig();
    auto container = buildContainer(config);

    // 2. Temporarily configure the server for the test (Port 0 automatically finds a free port!)
    auto settings = new HTTPServerSettings;
    settings.port = 0;
    settings.bindAddresses = ["127.0.0.1"];

    auto router = new URLRouter;
    router.registerRestInterface(new SubaccountApi(container.manageSubaccounts), "/rest/v1/");

    // 3. Start Server
    auto listener = listenHTTP(settings, router);

    // Get the dynamically assigned port from the operating system
    ushort myPort = listener.bindAddresses[0].port;
    string basisUrl = format("http://127.0.0.1:%d/rest/v1/", myPort);

    // Ensure that the server is stopped after the test (even in case of a crash)
scope (exit) {
        listener.stopListening;
    }

    // Flags to check the asynchronous outcome
    bool testSuccessful = false;
    string errorMessage = "";

    // 4. The trick: We start the client in its own Vibe.d task (Fiber)
    auto clientTask = runTask({
        try {
            auto clientSettings = new RestInterfaceSettings;
            clientSettings.baseURL = URL(basisUrl);

            // Client connects to the dynamic port
            auto client = new RestInterfaceClient!ISubaccountApi(basisUrl);

            testSuccessful = true;
        } catch (Throwable t) {
            errorMessage = t.msg;
        }
    });

    clientTask.join();

    // 6. Evaluation in the main test thread
    assert(testSuccessful, "REST-Test fails: " ~ errorMessage);
    logInfo("--- Service-Unittest successfully completed ---");
}
