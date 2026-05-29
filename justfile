# Rostra — task runner
# https://just.systems

set dotenv-load := true
set shell := ["bash", "-c"]

# ─── defaults ────────────────────────────────────────────────────────────────

default:
    @just --list

# ─── setup (run once on a fresh machine) ─────────────────────────────────────

# Install all project dependencies and prepare the environment
setup: _print-install-plan _require-system-deps _require-container-runtime _install-java _install-quarkus-cli _install-node-deps _copy-env _configure-testcontainers
    #!/usr/bin/env bash
    echo "                                                                      "
    echo "✅  Setup complete. Run 'just dev' to start developing.               "
    echo ""
    echo "💡  If 'java', 'quarkus', or 'node' are not found in your terminal,   "
    echo "    add the following paths to your shell config:                     "
    echo "    \$HOME/.sdkman/candidates/java/current/bin                        "
    echo "    \$HOME/.sdkman/candidates/quarkus/current/bin                     "
    echo "    \$HOME/.local/share/fnm                                           "
    echo ""
    echo "Dev UI available at http://localhost:8080/q/dev-ui. Provides:         "
    echo "  - Database inspection using the Agroal service.                     "
    echo "  - Swagger UI for API documentation.                                 "
    echo "  - Server configuration (live).                                      "
    echo ""
    echo "👀  Recommendation: install the React Developer Tools extension for your browser: https://react.dev/learn/react-developer-tools"

# ─── daily dev ───────────────────────────────────────────────────────────────

# Start everything needed for daily development (Quarkus dev mode + Vite + containers)
dev: _copy-env
    #!/usr/bin/env bash
    set -e
    trap 'kill 0' EXIT INT TERM
    just _dev-backend &
    just _dev-frontend &
    wait
    echo ""
    echo "Dev UI available at http://localhost:8080/q/dev-ui. Provides:         "
    echo "  - Database inspection using the Agroal service.                     "
    echo "  - Swagger UI for API documentation.                                 "
    echo "  - Server configuration (live).                                      "
    wait

# ─── individual starters (internal) ──────────────────────────────────────────

[private]
_dev-backend:
    cd server && ./mvnw quarkus:dev -Dstyle.color=always

[private]
_dev-frontend:
    cd client/web && npm run dev --color

# ─── build ───────────────────────────────────────────────────────────────────

# Build backend (JVM jar + container image via jib)
build-backend:
    cd server && ./mvnw package -DskipTests

# Build frontend (production bundle)
build-frontend:
    cd client/web && npm run build

# Build everything
build: build-backend build-frontend

# ─── database ───────────────────────────────────────────────────────────────

# Open a psql shell into the Dev Services PostgreSQL instance (requires just dev to be running)
db:
    #!/usr/bin/env bash
    if ! pg_isready -h localhost -p 5432 -U quarkus -q 2>/dev/null; then
        echo "❌  PostgreSQL is not reachable on localhost:5432."
        echo "    Make sure 'just dev' is running first."
        exit 1
    fi
    PGPASSWORD=quarkus psql -h localhost -p 5432 -U quarkus -d quarkus

# ─── test ────────────────────────────────────────────────────────────────────

# Run backend tests (JUnit 5 / REST Assured / Testcontainers)
test-backend:
    cd server && ./mvnw test

# Run frontend unit tests (Vitest)
test-frontend:
    cd client/web && npm run test

# Run frontend E2E tests (Playwright)
test-e2e:
    cd client/web && npx playwright test

# Run all tests
test: test-backend test-frontend

# ─── lint / format ───────────────────────────────────────────────────────────

# Format backend with Spotless
fmt-backend:
    cd server && ./mvnw spotless:apply

# Format frontend with Prettier
fmt-frontend:
    cd client/web && npm run format

# Format everything
fmt: fmt-backend fmt-frontend

# Check backend formatting (Spotless)
lint-backend:
    cd server && ./mvnw spotless:check

# Lint frontend
lint-frontend:
    cd client/web && npm run lint

# Lint everything
lint: lint-backend lint-frontend

# ─── install plan ────────────────────────────────────────────────────────────

[private]
_print-install-plan:
    #!/usr/bin/env bash
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║             Rostra — setup install plan                     ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  The following will be installed if not already present:    ║"
    echo "║                                                              ║"
    echo "║  System packages (pacman / apt)                             ║"
    echo "║    • curl, zip, unzip, git, fontconfig                      ║"
    echo "║    • ca-certificates            (Ubuntu only)               ║"
    echo "║                                                              ║"
    echo "║  Container runtime                                           ║"
    echo "║    • Podman (rootless)           if no runtime found        ║"
    echo "║      └─ slirp4netns, fuse-overlayfs                        ║"
    echo "║      └─ uidmap                  (Ubuntu only)               ║"
    echo "║                                                              ║"
    echo "║  Java                                                        ║"
    echo "║    • SDKMAN                                                  ║"
    echo "║    • OpenJDK 25.0.2 (25.0.2-open via SDKMAN)               ║"
    echo "║                                                              ║"
    echo "║    • Quarkus CLI 3.24.4       (via SDKMAN)                  ║"
    echo "║                                                              ║"
    echo "║  Node                                                        ║"
    echo "║    • fnm (Fast Node Manager)                                ║"
    echo "║    • Node.js LTS  (or pinned via .node-version)             ║"
    echo "║    • npm install  (frontend/ dependencies)                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

# ─── system dependencies ─────────────────────────────────────────────────────
# Prerequisites for SDKMAN, fnm, Java, and Node.
# Supports EndeavourOS/Arch (pacman) and Ubuntu/Debian (apt).

[private]
_require-system-deps:
    #!/usr/bin/env bash
    set -e

    _pkg_install() {
        if command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm "$@" 2>&1 | grep -E "^(installing|warning|error)" || true
        elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get install -y -q "$@"
        else
            echo "❌  Unsupported package manager. Install manually: $*" >&2
            exit 1
        fi
    }

    echo "🔍  Checking system dependencies …"

    if command -v pacman >/dev/null 2>&1; then
        PKGS="curl zip unzip git fontconfig"
    else
        sudo apt-get update -qq
        PKGS="curl zip unzip git fontconfig ca-certificates"
    fi

    MISSING=""
    for pkg in $PKGS; do
        if command -v pacman >/dev/null 2>&1; then
            pacman -Qi "$pkg" >/dev/null 2>&1 || MISSING="$MISSING $pkg"
        else
            dpkg -s "$pkg" >/dev/null 2>&1 || MISSING="$MISSING $pkg"
        fi
    done

    if [ -n "$MISSING" ]; then
        echo "📦  Installing missing system packages:$MISSING"
        _pkg_install $MISSING
    else
        echo "✔   All system dependencies present."
    fi

# ─── container runtime ───────────────────────────────────────────────────────
# Prefers Podman (rootless, daemonless). Falls back to Docker if already present.
# Installs Podman + rootless networking stack if no runtime is found.

[private]
_require-container-runtime:
    #!/usr/bin/env bash
    set -e

    if command -v podman >/dev/null 2>&1; then
        echo "✔   Podman $(podman --version | awk '{print $3}') already installed."
        just _ensure-podman-rootless
        exit 0
    fi

    if command -v docker >/dev/null 2>&1; then
        echo "✔   Docker $(docker --version | awk '{print $3}' | tr -d ',') found — using it for Dev Services."
        exit 0
    fi

    echo "📦  No container runtime found. Installing Podman …"
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm podman slirp4netns fuse-overlayfs 2>&1 | grep -E "^(installing|warning|error)" || true
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y -q podman slirp4netns fuse-overlayfs uidmap
    else
        echo "❌  Unsupported package manager. Please install Podman manually." >&2
        exit 1
    fi
    just _ensure-podman-rootless
    echo "✔   Podman $(podman --version | awk '{print $3}') installed."

[private]
_ensure-podman-rootless:
    #!/usr/bin/env bash
    set -e
    CURRENT_USER="$(id -un)"
    if ! grep -q "^${CURRENT_USER}:" /etc/subuid 2>/dev/null; then
        echo "🔧  Configuring rootless uid/gid maps for '${CURRENT_USER}' …"
        sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "${CURRENT_USER}"
        echo "✔   uid/gid maps configured. You may need to log out and back in."
    else
        echo "✔   Rootless Podman uid/gid maps already configured."
    fi

# ─── Testcontainers ──────────────────────────────────────────────────────────
# Points Testcontainers at Podman's rootless socket. No-op when Docker is used.

[private]
_configure-testcontainers:
    #!/usr/bin/env bash
    if ! command -v podman >/dev/null 2>&1; then
        exit 0
    fi

    SOCKET_PATH="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
    PROPS="$HOME/.testcontainers.properties"

    systemctl --user enable --now podman.socket 2>/dev/null || true

    if [ ! -f "$PROPS" ] || ! grep -q "docker.host" "$PROPS" 2>/dev/null; then
        echo "🔧  Configuring Testcontainers to use Podman socket …"
        printf 'docker.host=unix://%s\nryuk.disabled=true\n' "$SOCKET_PATH" >> "$PROPS"
        echo "✔   ~/.testcontainers.properties updated."
    else
        echo "✔   Testcontainers already configured."
    fi

# ─── Java (SDKMAN + OpenJDK 25) ──────────────────────────────────────────────

[private]
_install-java:
    #!/usr/bin/env bash
    set -e

    if [ ! -d "$HOME/.sdkman" ]; then
        echo "📦  Installing SDKMAN …"
        curl -s "https://get.sdkman.io" | bash >/dev/null
    else
        echo "✔   SDKMAN already installed."
    fi

    export SDKMAN_DIR="$HOME/.sdkman"
    source "$SDKMAN_DIR/bin/sdkman-init.sh"

    JAVA_VERSION="25.0.2-open"
    if sdk current java 2>/dev/null | grep -q "${JAVA_VERSION}"; then
        echo "✔   Java ${JAVA_VERSION} already active."
    elif [ -d "$SDKMAN_DIR/candidates/java/${JAVA_VERSION}" ]; then
        echo "✔   Java ${JAVA_VERSION} already installed."
    else
        echo "☕  Installing OpenJDK ${JAVA_VERSION} via SDKMAN…"
        sdk install java ${JAVA_VERSION} >/dev/null
    fi
    sdk default java ${JAVA_VERSION} >/dev/null
    echo "✔   $(java -version 2>&1 | head -1)"

# ─── Quarkus CLI (SDKMAN) ─────────────────────────────────────────────────────

[private]
_install-quarkus-cli:
    #!/usr/bin/env bash
    set -e

    export SDKMAN_DIR="$HOME/.sdkman"
    source "$SDKMAN_DIR/bin/sdkman-init.sh"

    QUARKUS_VERSION="3.36.0"
    if command -v quarkus >/dev/null 2>&1 && quarkus version 2>/dev/null | grep -q "${QUARKUS_VERSION}"; then
        echo "✔   Quarkus CLI ${QUARKUS_VERSION} already active."
    elif [ -d "$SDKMAN_DIR/candidates/quarkus/${QUARKUS_VERSION}" ]; then
        echo "✔   Quarkus CLI ${QUARKUS_VERSION} already installed."
        sdk default quarkus ${QUARKUS_VERSION} >/dev/null
    else
        echo "⚡  Installing Quarkus CLI ${QUARKUS_VERSION} via SDKMAN …"
        sdk install quarkus ${QUARKUS_VERSION} >/dev/null
    fi
    sdk default quarkus ${QUARKUS_VERSION} >/dev/null
    echo "✔   Quarkus CLI $(quarkus version)"

# ─── Node (fnm + LTS or pinned via .node-version) ────────────────────────────

[private]
_install-node-deps:
    #!/usr/bin/env bash
    set -e

    FNM_BIN="$HOME/.local/share/fnm/fnm"

    # Check the binary directly — don't rely on PATH (shell may be fish or others)
    if [ ! -x "$FNM_BIN" ]; then
        echo "📦  Installing fnm …"
        curl -fsSL https://fnm.vercel.app/install | bash -s -- \
            --install-dir "$HOME/.local/share/fnm" \
            --skip-shell \
            2>/dev/null
    else
        echo "✔   fnm $($FNM_BIN --version) already installed."
    fi

    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"

    if [ -f client/web/.node-version ] || [ -f client/web/.nvmrc ] || [ -f .node-version ]; then
        fnm install >/dev/null 2>&1
        fnm use >/dev/null 2>&1
    else
        fnm install --lts >/dev/null 2>&1
        fnm use lts-latest >/dev/null 2>&1
    fi
    echo "✔   Node $(node --version) / npm $(npm --version)"

    if [ -d client/web ]; then
        echo "📦  Installing frontend dependencies …"
        cd client/web && npm install --silent
    else
        echo "⚠️   No 'client/web' directory found — skipping npm install."
    fi

# ─── env ─────────────────────────────────────────────────────────────────────

[private]
_copy-env:
    #!/usr/bin/env bash
    if [ -f .env.example ] && [ ! -f .env ]; then
        cp .env.example .env
        echo "📄  .env created from .env.example — fill in any required secrets."
    fi
