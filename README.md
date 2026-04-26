# Keep Containers

A simple, robust shell script to manage container lifecycle by keeping only a specified number of the most recent containers and cleaning up the rest. It works with both **Docker** and **Podman**.

## Features

- **Multi-Runtime Support:** Compatible with both `docker` and `podman` CLI.
- **Prefix-based Filtering:** Target specific containers by their name prefix.
- **Customizable Retention:** Define how many recent containers you want to keep (defaults to 2).
- **Automated Cleanup:** Gracefully stops and force-removes older containers.
- **Safety First:** Implements strict error handling (`set -euo pipefail`).

## Prerequisites

- Bash 4.0 or higher
- `docker` or `podman` installed and in your PATH.

## Usage

```bash
./keep-containers.sh -p <prefix> -r <runtime> [-k <keep_count>] [-h]
```

### Options

| Option | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `-p` | Prefix of the container name to filter by. | Yes | - |
| `-r` | Container runtime CLI to use: `docker` or `podman`. | Yes | - |
| `-k` | Number of recent containers to keep. | No | 2 |
| `-h` | Show help message. | No | - |

### Examples

**Run using npx (without installation):**
```bash
npx keep-containers -p web-app -r docker -k 3
```

**Keep the 3 most recent Docker containers starting with "web-app":**
```bash
./keep-containers.sh -p web-app -r docker -k 3
```

**Keep the default (2) most recent Podman containers starting with "api-worker":**
```bash
./keep-containers.sh -p api-worker -r podman
```

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/erlangparasu/keep-containers.git
   cd keep-containers
   ```
2. Make the script executable:
   ```bash
   chmod +x keep-containers.sh
   ```

## License

This project is licensed under the terms of the MIT License. See [LICENSE](LICENSE) for details.
