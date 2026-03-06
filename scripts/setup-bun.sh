# Install bun if not present
if ! command -v bun &> /dev/null; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
else
    echo "bun is already installed."
fi

echo "Bun $(bun --version) installed successfully."
