# Ramparts Gemini CLI Integration Makefile

.PHONY: help install install-commands install-mcp setup test clean build docker demo docs lint format

# Default target
help:
	@echo "🛡️ Ramparts × Gemini CLI Integration"
	@echo "===================================="
	@echo ""
	@echo "Available targets:"
	@echo "  install          - Complete installation (TOML commands + MCP server)"
	@echo "  install-commands - Install TOML slash commands only"
	@echo "  install-mcp      - Install MCP server only"
	@echo "  setup            - Interactive setup with prerequisites check"
	@echo "  test             - Run all tests"
	@echo "  build            - Build MCP server"
	@echo "  docker           - Build and run Docker containers"
	@echo "  demo             - Run interactive demo"
	@echo "  docs             - Serve documentation locally"
	@echo "  lint             - Run linting"
	@echo "  format           - Format code"
	@echo "  clean            - Clean build artifacts"
	@echo "  uninstall        - Remove installation"
	@echo "  validate         - Validate installation"
	@echo ""
	@echo "Environment variables:"
	@echo "  GOOGLE_API_KEY   - Required for Gemini CLI"
	@echo "  RAMPARTS_PORT    - MCP server port (default: 3001)"
	@echo "  DEBUG            - Enable debug mode"

# Installation targets
install:
	@echo "🚀 Installing complete Ramparts × Gemini CLI integration..."
	@./scripts/setup-complete-integration.sh

install-commands:
	@echo "📋 Installing TOML slash commands..."
	@./scripts/install-slash-commands.sh --user

install-mcp:
	@echo "🔧 Installing MCP server..."
	@./scripts/install-mcp-server.sh

setup:
	@echo "⚙️ Running interactive setup..."
	@./scripts/setup-complete-integration.sh

# Development targets
build:
	@echo "🔨 Building MCP server..."
	@cd mcp-server && npm install && npm run build

test:
	@echo "🧪 Running tests..."
	@./scripts/validate-installation.sh
	@cd mcp-server && npm test

test-commands:
	@echo "📋 Testing TOML commands..."
	@bash -c 'if [ -d ~/.gemini/commands ]; then echo "✅ Commands directory exists"; else echo "❌ Commands not installed"; exit 1; fi'
	@bash -c 'if [ -f ~/.gemini/commands/ramparts-scan.toml ]; then echo "✅ ramparts-scan command found"; else echo "❌ ramparts-scan not found"; exit 1; fi'

test-mcp:
	@echo "🔧 Testing MCP server..."
	@cd mcp-server && npm test

# Docker targets
docker:
	@echo "🐳 Building and running Docker containers..."
	@docker-compose up --build -d

docker-build:
	@echo "🐳 Building Docker image..."
	@docker build -t ramparts/gemini-cli-integration .

docker-run:
	@echo "🐳 Running Docker containers..."
	@docker-compose up -d

docker-stop:
	@echo "🛑 Stopping Docker containers..."
	@docker-compose down

docker-logs:
	@echo "📄 Showing Docker logs..."
	@docker-compose logs -f

# Demo and documentation
demo:
	@echo "🧪 Running interactive demo..."
	@if [ -f examples/run-demo.sh ]; then \
		bash examples/run-demo.sh; \
	else \
		echo "Demo script not found. Running basic demo..."; \
		echo "1. Quick security check:"; \
		echo "   gemini"; \
		echo "   > /ramparts-quick config"; \
		echo ""; \
		echo "2. Scan specific server:"; \
		echo "   > /ramparts-scan https://api.example.com/mcp/"; \
		echo ""; \
		echo "3. Comprehensive audit:"; \
		echo "   > /ramparts-audit"; \
	fi

docs:
	@echo "📚 Serving documentation..."
	@echo "Documentation will be available at http://localhost:8080"
	@cd docs && python3 -m http.server 8080

docs-build:
	@echo "📚 Building documentation..."
	@mkdir -p dist/docs
	@cp -r docs/* dist/docs/
	@echo "Documentation built in dist/docs/"

# Code quality
lint:
	@echo "🔍 Running linting..."
	@if command -v eslint >/dev/null 2>&1; then \
		eslint . --ext .js,.ts,.json --fix; \
	else \
		echo "ESLint not found, skipping JavaScript linting"; \
	fi
	@if command -v shellcheck >/dev/null 2>&1; then \
		find scripts -name "*.sh" -exec shellcheck {} \;; \
	else \
		echo "Shellcheck not found, skipping shell script linting"; \
	fi

format:
	@echo "💅 Formatting code..."
	@if command -v prettier >/dev/null 2>&1; then \
		prettier --write .; \
	else \
		echo "Prettier not found, skipping formatting"; \
	fi

# Validation and cleanup
validate:
	@echo "✅ Validating installation..."
	@./scripts/validate-installation.sh

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf mcp-server/dist/
	@rm -rf mcp-server/node_modules/
	@rm -rf node_modules/
	@rm -rf dist/
	@rm -rf logs/
	@docker-compose down --volumes --remove-orphans 2>/dev/null || true

uninstall:
	@echo "🗑️ Uninstalling Ramparts × Gemini CLI integration..."
	@./scripts/install-slash-commands.sh --uninstall
	@./scripts/install-mcp-server.sh --uninstall
	@echo "✅ Uninstallation complete"

# Development helpers
dev-setup:
	@echo "🛠️ Setting up development environment..."
	@cd mcp-server && npm install
	@npm install

dev-run:
	@echo "🚀 Running development server..."
	@cd mcp-server && npm run dev

dev-test:
	@echo "🧪 Running development tests..."
	@cd mcp-server && npm run test:watch

# Release targets
package:
	@echo "📦 Creating distribution package..."
	@mkdir -p dist
	@tar -czf dist/ramparts-gemini-cli-integration.tar.gz \
		--exclude='node_modules' \
		--exclude='dist' \
		--exclude='.git' \
		--exclude='logs' \
		.
	@echo "✅ Package created: dist/ramparts-gemini-cli-integration.tar.gz"

release-check:
	@echo "🔍 Checking release readiness..."
	@./scripts/validate-installation.sh
	@echo "✅ Release checks passed"

# CI/CD helpers
ci-install:
	@echo "🤖 CI installation..."
	@./scripts/setup-complete-integration.sh --skip-checks --no-demo

ci-test:
	@echo "🤖 CI testing..."
	@make test
	@make validate

ci-build:
	@echo "🤖 CI build..."
	@make build
	@make docker-build

# Platform-specific targets
install-macos: install
install-linux: install
install-windows:
	@echo "🪟 Windows installation..."
	@powershell.exe -ExecutionPolicy Bypass -File scripts/install-windows.ps1

# Help for specific commands
help-install:
	@echo "Installation Help:"
	@echo "  make install          - Complete installation"
	@echo "  make install-commands - TOML commands only"
	@echo "  make install-mcp      - MCP server only"
	@echo "  make setup            - Interactive setup"

help-docker:
	@echo "Docker Help:"
	@echo "  make docker           - Build and run containers"
	@echo "  make docker-build     - Build image only"
	@echo "  make docker-run       - Run containers"
	@echo "  make docker-stop      - Stop containers"
	@echo "  make docker-logs      - Show container logs"

help-dev:
	@echo "Development Help:"
	@echo "  make dev-setup        - Setup development environment"
	@echo "  make dev-run          - Run development server"
	@echo "  make dev-test         - Run tests in watch mode"
	@echo "  make build            - Build MCP server"
	@echo "  make test             - Run all tests"