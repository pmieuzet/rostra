v0.1.0

Context: *Rostra* is a multi-tenant, action-oriented governance engine utilizing progressive disclosure. It facilitates community decision-making through a configurable rule engine (Arbitration Protocol) and asynchronous collaboration, avoiding passive discussion in favor of strict, actionable states (draft, arbitration, sealed, adopted, dismissed) and stances (endorse, suggest, clarify, oppose).

Technically, the project consists of a separate backend and frontend. For both, this document provides tooling requirements and architecture guidelines. It also provides global guidelines that apply to every part of the project.

Authentication note: the project leverages keycloak and OAuth2. User identity is managed via JWT tokens (OAuth2 / OpenID Connect). Supported OAuth providers includes Google and GitHub.

---

# 0. Globally applicable guidelines

- Keep coupling as low as possible, and cohesion as high as possible:
  - Law of Demeter: import only what is strictly required (`b.method()` rather than `a.b.method()`).
  - Coupling means how much modules interact with each others (code wise).
    Coupling from acceptable to worst: none > message > strict data > nested data > control meddling > external data > global data > data internal control.
  - Cohesion is related to the SRP principle: put together domain-related things that perform exactly 1 **action** (e.g. `register` or `place_order`).
- YAGNI: don't write code for something you don't need right now.
  Cover only the minimum requirment for the task, but do it well.
  When code repeats at least twice, consider a refactor leveraging patterns.
- KISS: the simpler, the better.
- Don't expose internals: encapsulate.
- Spend the time naming things properly and explicitly.
- Don't go down the rabbit hole nor the lazy path: leverage well-established patterns and libraries.
- Test must be deterministic.
- Errors are values: propagate failures explicitly; never swallow exceptions or promise rejections silently.
- Validate input at every trust boundary: user-submitted form data (frontend), the HTTP layer (backend), and any external service response.
- Favour choreography to orchestration where it makes sense.

## Observability

- Structured logging only: emit JSON logs with consistent fields (`timestamp`, `level`, `service`, `tenantId`, `userId`, `traceId`, `message`). Never use free-form `printf`-style logging (logging != debugging).
- Every inbound request must carry and propagate a `traceId` (W3C `traceparent` header). Generate one at the entry point if absent.
- Log levels: `ERROR` for unrecoverable faults, `WARN` for recoverable anomalies, `INFO` for significant state transitions (e.g. proposal adopted), `DEBUG` for development detail (stripped in production).

## Security & Authorization

- Keycloak handles authentication only. Authorization must be enforced at the application boundary.
- Principle of least privilege: every role, service account, and API scope must request only the permissions it strictly needs.
- Validate and sanitize all user-supplied input at the trust boundary before it reaches any business logic. Reject early; never sanitize-and-hope.
- Secrets must never be hardcoded or committed. Use environment variables, injected at runtime.

### Authorization model

The app has two orthogonal, non-exclusive authorization axes:

1. Role-Based (RBAC)
- Roles (`admin`, `moderator`, `membre`) are statically defined but dynamically assigned per space.
- Coarse-grained enforcement occurs at the HTTP boundary (Quarkus `@RolesAllowed`), using Keycloak roles carried in the JWT.
- Per-space configurable permissions are enforced in the application layer (never in the domain layer).

2. Attribute-Based (ABAC)
- A *steward* is not a role. It is a resource-scoped grant dynamically created and assigned by users.
- Checks are evaluated in the application layer, resolved by the use case before proceeding.
- The steward grant is modeled as a first-class domain value object: `StewardGrant(memberId, topicId, spaceId)`.

Enforcement order: HTTP boundary (RBAC, Keycloak roles) → use case entry (RBAC configurable rules + ABAC steward check) → domain method (pure business logic, no authZ).

## API Contract

- OpenAPI is the source of truth for the REST API. The spec is generated from backend annotations (Quarkus SmallRye OpenAPI) and must always be up to date.
- API versioning: prefix all routes with `/api/v{n}/`. Increment the major version only on breaking changes. Minor, additive changes do not require a version bump.
- The frontend consumes the API through `orval`, which generates fully-typed TanStack Query hooks directly from the OpenAPI spec. Manual fetch wrappers duplicating the contract are forbidden.

# 1. FRONTEND

Frontend is mobile-first, targeting android, iOS, web.

## Language & Frameworks

- TypeScript 6.0.
- React 19.2.
- Shadcn 4.8.
- Tailwind 4.3.
- Testing: Vitest, React Testing Library, Playwright (E2E).
- Formatting: Prettier.
- CI: multi-stage Dockerfile (Node builder -> Nginx alpine runner)

## Architecture

Frontend applies a slightly adapted [FSD](https://feature-sliced.design): no widgets folder (until necessary), shared folder is replaced by kernel + components folders.

It relies on technical *layers*:  
- *apps* - the package you'll run. Routing, entrypoint, providers. Glue & config only.
- *pages* - one crate per individual, plain page (1:1 app route). Composition through UI. No logic (mostly).
- *widgets* - self-contained structural UI blocks. Composition: connects features. (use pages unless a widget is necessary, i.e. reusable across multiple pages)
- *features* - user actions (e.g. add_to_cart). Heavy logic. Must be **verbs**. What is the user doing?
- *entities* - business data, used across project (e.g. user or product). Must be **nouns**. What is this object?
- *components* - reusable, nearly atomic, pure UI components. No business logic.
- *kernel* - core functionalities reused across the upper layers (e.g. i18n). No business logic.

*pages* *widgets* *features* *entities* modules consist of *slices*. They divide their layer by domain.

Each slice holds technical segments: 
- *ui* - UI display ; such as components, styles, layout.
- *model* - Data model ; schemas, interfaces, stores, and business logic.
- *api* - backend interactions: request functions, data types, mappers, etc.
- On rare occasions: *lib* - library code that other modules on this slice need.

## Rules

- A module can only import modules from lower layers (no siblings, no parents).
- No technical division in segments (e.g. no `hooks.ts`)
  If a segment gets too big: divide such as each file reflects the domain it represents.
- *kernel* & *components* are a last resort, they only contains pieces you could use in a totally different app.
- All translations go into `/assets/lang`
- Logic must be colocated with UI at the slice level. One exception: `/kernel` contains only logic, in such case ui goes into `/features`.
- Focus testing on:
  - *features* logic with Vitest, behaviour with React Testing Library,
  - *entities* logic with Vitest,
  - *components* and *widgets* interaction using React Testing Library.

### State Management

Three distinct categories of state, each with a dedicated owner:

| Category | Owner | Example |
|---|---|---|
| Server state | TanStack Query | proposal list, user profile |
| Global client state | React Context (+ `useReducer`) | authenticated session, active tenant |
| Local UI state | `useState` / `useReducer` | modal open, input focus |

- **Server state is never duplicated into a global store.** TanStack Query is the single source of truth for remote data: fetching, caching, revalidation, and optimistic updates.
- Global client state is reserved for truly cross-cutting concerns (auth session, active tenant). Do not inflate it.
- Derive state; don't synchronise state. If a value can be computed from existing state or a query result, compute it — don't store it separately.

### Async & Data Fetching

- All server interactions go through TanStack Query (`useQuery` / `useMutation`). No raw `useEffect` for data fetching.
- Every query and mutation must handle three states explicitly in the UI: loading, error, success. Use Suspense boundaries and error boundaries at the page or widget level.
- Optimistic updates (`useMutation` `onMutate`) must be used for latency-sensitive user actions (stance changes, endorsements).
- API calls are colocated in the `api` segment of their slice. They use the typed client generated from the OpenAPI spec.

### Form Handling

- All forms use React Hook Form with *Zod* schemas for validation.
- The Zod schema is the single source of truth for a form's shape and constraints; it also serves as the TypeScript type via `z.infer`.
- Schema definitions live in the `model` segment of the relevant slice.
- Never validate on the server only: show inline, field-level errors immediately client-side.

### Accessibility (a11y)

- All interactive elements must be keyboard-navigable and have a visible focus indicator.
- Use semantic HTML. Decorative ARIA roles are a last resort when no native element fits.
- Every image and icon conveying meaning must have a descriptive `alt` attribute or `aria-label`. Decorative images use `alt=""`.
- Colour contrast must meet WCAG 2.1 AA at minimum.
- Shadcn components are built on Radix UI primitives, which are accessible by default — do not override their ARIA attributes without good reason.

### Environment & Configuration

- All environment variables are prefixed `VITE_`.
- No environment variable is read directly in component or feature code. They are centralised in `kernel/config` and re-exported as typed constants.
- Do not expose secrets (private keys, client secrets) in frontend environment variables.

# 2. BACKEND

## Language & Frameworks

- Backend: Java 25, using Quarkus 3.35 (w/ Panache).
- Database: PostgreSQL 18.
- Authentication: Keycloak and OAuth2.
- Testing: JUnit 5, Mockito, REST Assured, Testcontainers.
- Formatting: Spotless.
- CI: no dockerfile required, we use `quarkus-container-image-jib` to build container images.

## Architecture

Backend applies a hexagonal architecture (ports and adapters) organised *domain-first*: the top-level package is the *business slice*, not the *technical layer*.

Package convention: `com.rostra.{slice}.{layer}`

Layers within each business slice:
- *domain*: business entities (Records), value objects, business rules, domain exceptions. Framework-agnostic.
- *application* (ports): use cases, outbound port interfaces. Framework-agnostic.
- *infra* (adapters): Quarkus REST endpoints, Panache repositories, external service clients.

Operational infrastructure (health checks, metrics) that belongs to no business domain lives directly under `com.rostra.infra`, outside any slice.

## Rules

### Purity
- Dependency Inversion: inner layers must never depend on outer layers.
- Domain purity: the domain and application packages must be framework-agnostic.
- Data Mapping: infrastructure objects must never leak into the domain.
- Backend application is stateless: session state is managed by Keycloak (JWT); application state is managed by PostgreSQL.

### Domain & Application (Core & Ports)
- Domain entities must encapsulate their behavior. No setters. State modifications must occur exclusively in business methods.
- Domain entities must be modeled using native Java 25 Records.
- Use Java Records to group related attributes into immutable concepts. For example, `Money` record instead of a raw decimal, `Email` record instead of a raw string.
- Use case classes must act strictly as a coordinator: fetching data via outbound ports, calling business methods on the domain entity, and saving the state. It must not contain business logic.

### Infrastructure & Adapters
- Isolated repository adapter: database interactions must use the Panache Repository pattern, never the Active Record pattern. `PanacheRepository`s must be located exclusively in the infrastructure layer and implement an outbound port interface.
- DTO Boundaries: web endpoints must consume and produce dedicated REST DTOs named `XxxRequest` (inbound) and `XxxResponse` (outbound). Never reuse the same DTO for both directions.
- DTO mapping: Use `MapStruct` (`quarkus-mapstruct` extension with `@Inject`).
- Authentication Boundary: Keycloak token validation occurs exclusively in the infrastructure layer.

### Error Handling
- The domain layer must only throw pure Java runtime exceptions expressing business violations. e.g. `UserNotActiveException`.
- Domain exceptions are intercepted by the infrastructure web adapter using Quarkus `ExceptionMapper` and translate these errors into standardized HTTP responses like 300+ and 400+.

### Multi-Tenancy

- Tenancy is enforced with **row-level isolation**: every tenant-scoped table carries a `tenant_id` column. There are no separate schemas or databases per tenant.
- The `tenantId` is extracted from the validated JWT (`tid` claim) exclusively in the infrastructure layer and propagated inward as a plain value object — never read from a thread-local or static context inside the domain.
- Every outbound port method that queries tenant-scoped data must accept `TenantId` as an explicit parameter. Implicit, ambient tenant context is forbidden.
- Repositories must always append a `tenant_id = :tenantId` predicate to every query. A missing predicate is a critical security defect.
- Cross-tenant data access is only permitted through explicitly named, audited use cases.

### Concurrency & Optimistic Locking

- All tenant-scoped, mutable aggregate roots must carry a `version` field managed by JPA optimistic locking (`@Version`).
- The infrastructure Panache entity holds the `@Version` field; the domain Record carries it as a plain `long version` and returns the updated value from business methods.
- On `OptimisticLockException`, the infrastructure layer translates it to HTTP `409 Conflict`. The client is responsible for retrying.
- Pessimistic locking is forbidden unless a specific, documented performance or correctness analysis justifies it.

### Transaction Boundaries

- `@Transactional` belongs exclusively on the application layer (use case classes). Never on domain methods, repository implementations, or REST endpoints.
- A use case is one transaction. If an operation spans multiple aggregates, model it as a single use case with a single transaction, or introduce a domain event to decouple it asynchronously.
- Read-only use cases must be annotated `@Transactional(readOnly = true)` to allow database-level optimisations.

### Domain Events

- State transitions on aggregate roots (e.g. `ProposalAdopted`, `StanceCast`) must publish a domain event after the state change is persisted.
- Domain events are plain Java Records defined in the *domain* layer. They carry only the data needed by consumers: no framework types, no infrastructure references.
- In-process event dispatch uses the CDI `Event<T>` bus (Quarkus). Observers are infrastructure-layer components (e.g. notification sender, audit log writer).
- The domain entity raises events; the use case collects and fires them after the repository save. This preserves transactional consistency (fire after commit using `@Observes(during = AFTER_SUCCESS)`).
- Current scope is in-process only. No transactional outbox is necessary until we need webhooks.

### Pagination & Queries

- All list endpoints are paginated using offset-based pagination (`page` + `size` query parameters). Cursor-based pagination is reserved for real-time feeds.
- Sorting is expressed as `sort=field` + `order=asc|desc` query parameters. Only explicitly whitelisted fields may be sorted on.
- Filter parameters are additive (AND semantics). Complex filtering is not exposed via REST; introduce a dedicated query endpoint if required.

### Testing
- Mocking Boundary: All unit tests for use cases must mock the outbound ports. Never boot the database container for use case testing.
- *domain* (*core*) -> unit tests.
- *infrastructure* (*adapters*) -> integration tests using `@QuarkusTest` and Testcontainers with a real database container + Keycloak.
- *application* (*ports*) -> mockito on all outbound ports (web endpoints). No database mounted.

# 3. OPS

## Local Development

- (Once) On a fresh machine, run `just setup` to install dependencies, set the environment, and start the database container.
- (Daily) Locally, run `just dev` to develop and test the application.

Note: do not install PostgreSQL or Keycloak directly as Quarkus Dev Services will automatically provision and manage ephemeral Docker containers.

## Environment Variables

- All environment variables are declared in a `.env.example` file committed to the repository. The actual `.env` file is gitignored.
- Application code never reads `System.getenv()` directly: backend variables are injected via Quarkus `@ConfigProperty`; frontend variables are centralised in `kernel/config` and re-exported as typed constants.
- Never expose secrets (private keys, client secrets) in frontend environment variables: they are visible to the browser.

## Git & Collaboration

- Trunk-based development: the main branch (`main`) is always releasable. All work is done in short-lived feature branches merged via reviewed pull request.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <subject>` — e.g. `feat(proposal): add arbitration timeout rule`. Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`.
- Commits must be atomic: one logical change per commit. Do not mix refactors with feature work in the same commit.
- Pull requests must pass all CI checks (build, lint, tests) before merge. No force-pushing to `main`.
