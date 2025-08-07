#!/bin/bash
echo "Starting development environment..."
echo "Current directory: $(pwd)"
echo "Go version: $(go version)"
echo "Python version: $(python3 --version)"
echo "Available commands:"
echo "  - go run ./cmd/server     # Run the server"
echo "  - go build ./cmd/server   # Build the server"
echo "  - dlv debug ./cmd/server  # Debug the server"
echo "  - go mod download         # Download dependencies"
echo "  - go mod tidy             # Tidy dependencies"
echo ""
echo "Starting bash shell..."
exec bash