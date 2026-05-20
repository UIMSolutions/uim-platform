# UIM ABAP Compiler Platform Service

A microservice implementing an **SAP ABAP 7.51 compiler pipeline** — lexer,
parser, semantic analyser, and IR code generator. Built with **D** and
**vibe.d**, following **Clean Architecture** and **Hexagonal Architecture**
(Ports & Adapters) principles.

Part of the [UIM Platform](https://www.sueel.de/uim/sap) suite.
Based on: [SAP ABAP Keyword Documentation 7.51](https://help.sap.com/doc/abapdocu_751_index_htm/7.51/de-DE/abenabap_overview.htm)

---

## Features

| Capability | Description |
|---|---|
| **Lexer** | Tokenises ABAP source: keywords, identifiers, string/integer literals, comments (`"` / `*`), operators, chain colon, statement period |
| **Parser** | Recursive-descent parser producing a `ParsedStatement` list covering all ABAP programming models (reports, class pools, function groups, OO, DB access) |
| **Semantic Analyser** | Validates block nesting (`IF`/`ENDIF`, `LOOP`/`ENDLOOP`, `CLASS`/`ENDCLASS`, …), detects deprecated `PERFORM` usage, reports unclosed blocks |
| **Code Generator** | Emits a flat Intermediate Representation (IR) text format from valid statement lists |
| **Program Repository** | CRUD management of ABAP source artefacts (in-memory; replaceable via port interface) |
| **Compilation Job Tracking** | Every compile request creates a persisted job record with full diagnostic and IR output |
| **REST API** | vibe.d HTTP server exposing full CRUD + compile endpoints |
| **CLI** | Interactive REPL (`--cli` flag) for local `compile <file>` / `check <file>` workflows |

---

## Architecture

```
abap-compiler/
├── source/
│   ├── app.d                          # Entry point: HTTP server + CLI dispatcher
│   └── uim/platform/abap_compiler/
│       ├── domain/                    # Pure business logic — no framework deps
│       │   ├── types.d                #   Strong-typed IDs, enums (ProgramType, TokenType…)
│       │   ├── entities/              #   AbapProgram, Token, Diagnostic, CompilationJob
│       │   ├── ports/repositories/    #   AbapProgramRepository, CompilationJobRepository
│       │   └── services/              #   AbapLexer, AbapParser, SemanticAnalyser, CodeGenerator
│       ├── application/               # Use cases — orchestrate domain
│       │   ├── dto.d                  #   Request/Response DTOs, CommandResult
│       │   └── usecases/
│       │       ├── compile.d          #   CompileUseCase (full 4-stage pipeline)
│       │       └── manage/
│       │           ├── programs.d     #   ManageProgramsUseCase
│       │           └── jobs.d         #   ManageJobsUseCase
│       ├── infrastructure/            # Adapters — driven side
│       │   ├── config.d               #   SrvConfig (env vars ABAPCOMPILER_HOST/PORT)
│       │   ├── persistence/memory/    #   MemoryAbapProgramRepository, MemoryCompilationJobRepository
│       │   └── container.d            #   Dependency-injection wiring
│       └── presentation/              # Adapters — driving side
│           ├── http/controllers/      #   ProgramController, CompileController, JobController, HealthController
│           └── cli/                   #   AbapCliRunner (REPL)
├── Dockerfile                         # Multi-stage Docker build
├── Containerfile                      # OCI / Podman build
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── dub.sdl
├── README.md
├── UML.md
└── NAFv4.md
```

---

## ABAP Compiler Pipeline

```
Source Code (string)
       │
       ▼
 ┌─────────────┐
 │  AbapLexer  │  → Token[]
 └─────────────┘
       │
       ▼
 ┌─────────────┐
 │  AbapParser │  → ParseResult { ParsedStatement[], Diagnostic[] }
 └─────────────┘
       │
       ▼
 ┌──────────────────┐
 │ SemanticAnalyser │  → Diagnostic[]
 └──────────────────┘
       │
       ▼
 ┌───────────────┐
 │ CodeGenerator │  → string[] (IR lines)
 └───────────────┘
       │
       ▼
 CompilationJob persisted with status + diagnostics + IR
```

---

## ABAP Language Support (Release 7.51)

Based on the official SAP ABAP documentation:

| Construct | Status |
|---|---|
| Report / executable programs (`REPORT`) | Supported |
| ABAP Objects: `CLASS … IMPLEMENTATION … ENDCLASS` | Supported |
| Interfaces: `INTERFACE … ENDINTERFACE` | Supported |
| Methods: `METHOD … ENDMETHOD` | Supported |
| Data declarations: `DATA`, `TYPES`, `FIELD-SYMBOLS` | Tokenised |
| Flow control: `IF/ENDIF`, `LOOP/ENDLOOP`, `WHILE/ENDWHILE`, `DO/ENDDO` | Block-checked |
| Exception handling: `TRY/ENDTRY` | Block-checked |
| Open SQL: `SELECT … FROM … WHERE … INTO … ENDSELECT` | Block-checked |
| Function groups: `FUNCTION-POOL`, `FUNCTION/ENDFUNCTION` | Supported |
| Subroutines: `FORM/ENDFORM` | Deprecated warning |
| String / integer literals, comments | Fully lexed |
| Chain statements (`:`) | Tokenised |

---

## API Endpoints

### Programs
| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/abap/programs` | List all programs for tenant |
| `POST` | `/api/v1/abap/programs` | Create a new program |
| `GET` | `/api/v1/abap/programs/:id` | Get program by ID |
| `PUT` | `/api/v1/abap/programs/:id` | Update program source |
| `DELETE` | `/api/v1/abap/programs/:id` | Delete program |

### Compiler
| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/abap/compile` | Compile by `programId` or inline `sourceCode` |

### Jobs
| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/abap/jobs` | List all compilation jobs |
| `GET` | `/api/v1/abap/jobs/:id` | Get job detail (diagnostics + IR) |
| `DELETE` | `/api/v1/abap/jobs/:id` | Delete job record |

### Health
| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/health` | Liveness / readiness probe |

---

## Compile Request Body

```json
{
  "programId": "Z_HELLO_WORLD",
  "sourceCode": "REPORT z_hello_world.\nWRITE 'Hello World'."
}
```

Either `programId` (stored program) or `sourceCode` (inline) must be provided.

---

## CLI Usage

```bash
# Start interactive REPL
./uim-abap-compiler-platform-service --cli

# Inside the REPL:
abap> compile my_program.abap
abap> check   my_program.abap
abap> help
abap> exit
```

---

## Running with Docker

```bash
docker build -t uim-abap-compiler .
docker run -p 8093:8093 uim-abap-compiler
```

## Running with Podman

```bash
podman build -f Containerfile -t uim-abap-compiler .
podman run -p 8093:8093 uim-abap-compiler
```

## Deploying to Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Building from Source

```bash
cd abap-compiler
dub build --config=defaultRun
./build/uim-abap-compiler-platform-service
```

## Running Tests

```bash
dub test --config=defaultTest
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `ABAPCOMPILER_HOST` | `0.0.0.0` | Bind address |
| `ABAPCOMPILER_PORT` | `8093` | Listen port |

---

## References

- [SAP ABAP Keyword Documentation 7.51 — Übersicht](https://help.sap.com/doc/abapdocu_751_index_htm/7.51/de-DE/abenabap_overview.htm)
- [ABAP Objects Overview](https://help.sap.com/doc/abapdocu_751_index_htm/7.51/de-DE/abenabap_objects_oview.htm)
- [Open SQL](https://help.sap.com/doc/abapdocu_751_index_htm/7.51/de-DE/abenopen_sql_glosry.htm)
