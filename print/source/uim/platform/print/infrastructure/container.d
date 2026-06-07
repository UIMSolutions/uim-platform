/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.infrastructure.container;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

struct Container {
    // Use cases
    ManagePrintQueuesUseCase managePrintQueuesUseCase;
    ManagePrintTasksUseCase managePrintTasksUseCase;
    ManagePrintersUseCase managePrintersUseCase;
    ManagePrintDocumentsUseCase managePrintDocumentsUseCase;
    ManagePrintClientsUseCase managePrintClientsUseCase;

    // HTTP controllers
    PrintQueueController printQueueController;
    PrintTaskController printTaskController;
    PrinterController printerController;
    PrintDocumentController printDocumentController;
    PrintClientController printClientController;
    HealthController healthController;

    // Web controllers
    PrintWebController printWebController;

    // CLI controllers
    PrintCliController printCliController;
}

Container buildContainer(SrvConfig config) @trusted {
    Container c;

    PrintQueueRepository queueRepo;
    PrintTaskRepository taskRepo;
    PrinterRepository printerRepo;
    PrintDocumentRepository docRepo;
    PrintClientRepository clientRepo;

    final switch (config.backend) {
        case PersistenceBackend.memory:
            queueRepo = new MemoryPrintQueueRepository();
            taskRepo = new MemoryPrintTaskRepository();
            printerRepo = new MemoryPrinterRepository();
            docRepo = new MemoryPrintDocumentRepository();
            clientRepo = new MemoryPrintClientRepository();
            break;

        case PersistenceBackend.file_:
            import std.file : mkdirRecurse, exists;
            if (!config.dataDir.exists) mkdirRecurse(config.dataDir);
            queueRepo = new FilePrintQueueRepository(config.dataDir);
            taskRepo = new FilePrintTaskRepository(config.dataDir);
            printerRepo = new FilePrinterRepository(config.dataDir);
            docRepo = new FilePrintDocumentRepository(config.dataDir);
            clientRepo = new FilePrintClientRepository(config.dataDir);
            break;

        case PersistenceBackend.mongodb:
            import vibe.db.mongo.mongo : connectMongoDB;
            auto mongo = connectMongoDB(config.mongoUri);
            auto db = mongo.getDatabase(config.mongoDb);
            queueRepo = new MongoPrintQueueRepository(db["print_queues"]);
            taskRepo = new MongoPrintTaskRepository(db["print_tasks"]);
            printerRepo = new MongoPrinterRepository(db["printers"]);
            docRepo = new MongoPrintDocumentRepository(db["print_documents"]);
            clientRepo = new MongoPrintClientRepository(db["print_clients"]);
            break;
    }

    // Use cases
    c.managePrintQueuesUseCase = new ManagePrintQueuesUseCase(queueRepo);
    c.managePrintTasksUseCase = new ManagePrintTasksUseCase(taskRepo);
    c.managePrintersUseCase = new ManagePrintersUseCase(printerRepo);
    c.managePrintDocumentsUseCase = new ManagePrintDocumentsUseCase(docRepo);
    c.managePrintClientsUseCase = new ManagePrintClientsUseCase(clientRepo);

    // HTTP controllers
    c.printQueueController = new PrintQueueController(c.managePrintQueuesUseCase);
    c.printTaskController = new PrintTaskController(c.managePrintTasksUseCase);
    c.printerController = new PrinterController(c.managePrintersUseCase);
    c.printDocumentController = new PrintDocumentController(c.managePrintDocumentsUseCase);
    c.printClientController = new PrintClientController(c.managePrintClientsUseCase);
    c.healthController = new HealthController();

    // Web controller
    c.printWebController = new PrintWebController(c.managePrintQueuesUseCase, c.managePrintTasksUseCase);

    // CLI controller
    c.printCliController = new PrintCliController(
        c.managePrintQueuesUseCase,
        c.managePrintTasksUseCase,
        c.managePrintersUseCase
    );

    return c;
}
