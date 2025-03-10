# Toast.sh Architecture

## Overview

Toast.sh is a Python-based CLI tool that provides various utility commands for AWS and Kubernetes management. The architecture follows a plugin-based design pattern, allowing for easy extension of functionality through the addition of new plugins.

## Components

### Main Application (toast.py)

The main entry point of the application is responsible for:
- Dynamically discovering and loading plugins from the `plugins` directory
- Registering plugin commands with the CLI interface using Click
- Running the CLI with all discovered commands

### Plugin System

The plugin system is based on Python's `importlib` and `pkgutil` modules, which enable dynamic loading of modules at runtime. This allows the application to be extended without modifying the core code.

#### Core Plugin Components

1. **BasePlugin (`plugins/base_plugin.py`)**
   - Abstract base class that all plugins must extend
   - Defines the interface for plugins
   - Provides registration mechanism for adding commands to the CLI

2. **Utilities (`plugins/utils.py`)**
   - Common utility functions used by multiple plugins
   - Examples include the `select_from_list` function for interactive selection

### Plugin Structure

Each plugin follows a standard structure:
- Inherits from `BasePlugin`
- Defines a unique `name` and `help` text
- Implements `execute()` method containing the command logic
- Optionally overrides `get_arguments()` to define custom command arguments

### Plugin Loading Process

1. The application scans the `plugins` directory for Python modules
2. Each module is imported and examined for classes that extend `BasePlugin`
3. Valid plugin classes are instantiated and registered with the CLI
4. Click handles argument parsing and command execution

## Current Plugins

| Plugin | Command | Description |
|--------|---------|-------------|
| AmPlugin | am | Show AWS caller identity |
| CdwPlugin | cdw | Navigate to workspace directories |
| CtxPlugin | ctx | Manage Kubernetes contexts |
| EnvPlugin | env | Set environment with AWS profile |
| RegionPlugin | region | Set AWS region |
| SsmPlugin | ssm | Run AWS SSM commands |
| UpdatePlugin | update | Update CLI tool |

### Plugin Details

#### EnvPlugin (env command)

The `env` command handles AWS environment profile management:

1. **Environment Path Discovery**:
   - Looks for AWS_ENV_PATH in the .env file in the current directory
   - If not found, creates a path at ~/workspace/github.com/{username}/keys/env
   - Uses whoami to get the default username, but allows customization

2. **Profile Management**:
   - Lists and allows selection of profiles from the environment path
   - Loads environment variables from the selected profile file
   - Sets AWS_PROFILE environment variable

3. **Authentication Verification**:
   - Verifies credentials by calling AWS STS get-caller-identity
   - Displays AWS region if available

4. **File Structure**:
   - Environment profiles are stored as files in the env directory
   - Each file contains key=value pairs for environment variables

## Dependencies

The plugin system has the following external dependencies:
- Click: Command-line interface creation
- Python-Dotenv: Environment variable management from .env files

## Adding New Plugins

To add a new plugin:
1. Create a new Python file in the `plugins` directory
2. Define a class that extends `BasePlugin`
3. Implement the required methods (`execute` and optionally `get_arguments`)
4. Set the `name` and `help` class variables

The plugin will be automatically discovered and loaded when the application starts.

## Benefits of the Plugin Architecture

- **Modularity**: Each command is isolated in its own module
- **Extensibility**: New commands can be added without modifying existing code
- **Maintainability**: Code is organized into logical components
- **Testability**: Plugins can be tested independently
