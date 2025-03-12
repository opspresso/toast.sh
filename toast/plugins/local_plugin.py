#!/usr/bin/env python3

import click
import os
import re
import subprocess
import json
from datetime import datetime
from toast.plugins.base_plugin import BasePlugin


class LocalPlugin(BasePlugin):
    """Plugin for 'local' command - manages .env.local files."""

    name = "local"
    help = "Manage .env.local files"

    @classmethod
    def get_arguments(cls, func):
        func = click.argument("command", required=False)(func)
        return func

    @classmethod
    def execute(cls, command=None, **kwargs):
        # Get the current path
        current_path = os.getcwd()
        
        # Check if .env.local exists in the current directory
        local_env_path = os.path.join(current_path, ".env.local")
        
        # Check if the current path matches the workspace pattern
        pattern = r"^(.*/workspace/github.com/[^/]+/[^/]+).*$"
        match = re.match(pattern, current_path)
        
        # Handle different commands
        if command == "ls":
            # List all parameters under /toast/ in AWS SSM Parameter Store
            try:
                # Check if aws CLI is available
                result = subprocess.run(["aws", "--version"], capture_output=True, text=True)
                if result.returncode != 0:
                    click.echo("Error: AWS CLI not found. Please install it to use this feature.")
                    return
                
                click.echo("Listing all .env.local parameters in AWS SSM Parameter Store...")
                
                # List parameters with path /toast/local/
                result = subprocess.run([
                    "aws", "ssm", "get-parameters-by-path",
                    "--path", "/toast/local/",
                    "--recursive",
                    "--output", "json"
                ], capture_output=True, text=True)
                
                if result.returncode != 0:
                    click.echo(f"Error listing parameters: {result.stderr}")
                    return
                
                try:
                    response = json.loads(result.stdout)
                    parameters = response.get("Parameters", [])
                    
                    if not parameters:
                        click.echo("No parameters found under /toast/local/ path.")
                        return
                    
                    click.echo("\nAWS SSM Parameters:")
                    click.echo("=" * 50)
                    
                    # Filter parameters containing env-local
                    env_params = [p for p in parameters if "env-local" in p.get("Name", "")]
                    
                    for param in env_params:
                        param_name = param.get("Name", "")
                        last_modified = param.get("LastModifiedDate", "")
                        
                        # Format the date if it exists (it's a timestamp in AWS response)
                        if last_modified and not isinstance(last_modified, str):
                            last_modified = datetime.fromtimestamp(last_modified).strftime('%Y-%m-%d %H:%M:%S')
                        
                        click.echo(f"{param_name} (Last Modified: {last_modified})")
                    
                    # Now list local .env.local files in ~/toast/
                    click.echo("\nLocal .env.local files:")
                    click.echo("=" * 50)
                    
                    toast_dir = os.path.expanduser("~/toast")
                    if os.path.exists(toast_dir):
                        for root, dirs, files in os.walk(toast_dir):
                            if ".env.local" in files:
                                rel_path = os.path.relpath(root, toast_dir)
                                file_path = os.path.join(root, ".env.local")
                                file_time = os.path.getmtime(file_path)
                                modified_time = datetime.fromtimestamp(file_time).strftime('%Y-%m-%d %H:%M:%S')
                                
                                if rel_path == ".":
                                    click.echo(f"~/toast/.env.local (Last Modified: {modified_time})")
                                else:
                                    click.echo(f"~/toast/{rel_path}/.env.local (Last Modified: {modified_time})")
                    else:
                        click.echo("No local toast directory found.")
                    
                except json.JSONDecodeError:
                    click.echo("Error parsing AWS SSM response.")
            except Exception as e:
                click.echo(f"Error: {e}")
                
        elif command == "up":
            # Upload local .env file to AWS SSM Parameter Store
            if not os.path.exists(local_env_path):
                click.echo("Error: .env.local not found in current directory.")
                return
                
            if not match:
                click.echo("Error: Current directory is not in a recognized workspace structure.")
                return
                
            # Extract project and org info
            project_root = match.group(1)
            project_name = os.path.basename(project_root)
            org_name = os.path.basename(os.path.dirname(project_root))
            
            # Read the local .env file
            with open(local_env_path, 'r') as file:
                content = file.read()
            
            # Create the SSM parameter path
            ssm_path = f"/toast/local/{org_name}/{project_name}/env-local"
            
            # Upload to SSM as SecureString
            try:
                # Check if aws CLI is available
                result = subprocess.run(["aws", "--version"], capture_output=True, text=True)
                if result.returncode != 0:
                    click.echo("Error: AWS CLI not found. Please install it to use this feature.")
                    return
                
                # Upload to SSM
                click.echo(f"Uploading .env.local to AWS SSM Parameter Store at {ssm_path}...")
                
                # Create a temporary file to avoid command line issues with quotes
                temp_file_path = os.path.expanduser("~/toast_temp_content.txt")
                with open(temp_file_path, 'w') as temp_file:
                    temp_file.write(content)
                
                # Use AWS CLI to put the parameter
                result = subprocess.run([
                    "aws", "ssm", "put-parameter",
                    "--name", ssm_path,
                    "--type", "SecureString",
                    "--value", "file://" + temp_file_path,
                    "--overwrite"
                ], capture_output=True, text=True)
                
                # Remove the temporary file
                os.remove(temp_file_path)
                
                if result.returncode == 0:
                    click.echo(f"Successfully uploaded .env.local to AWS SSM at {ssm_path}")
                else:
                    click.echo(f"Error uploading to AWS SSM: {result.stderr}")
            except Exception as e:
                click.echo(f"Error: {e}")
                
        elif command == "down":
            # Download .env file from AWS SSM Parameter Store
            if not match:
                click.echo("Error: Current directory is not in a recognized workspace structure.")
                return
                
            # Extract project and org info
            project_root = match.group(1)
            project_name = os.path.basename(project_root)
            org_name = os.path.basename(os.path.dirname(project_root))
            
            # Create the SSM parameter path
            ssm_path = f"/toast/local/{org_name}/{project_name}/env-local"
            
            # Download from SSM
            try:
                # Check if aws CLI is available
                result = subprocess.run(["aws", "--version"], capture_output=True, text=True)
                if result.returncode != 0:
                    click.echo("Error: AWS CLI not found. Please install it to use this feature.")
                    return
                
                # Try to get the parameter
                click.echo(f"Downloading from AWS SSM Parameter Store at {ssm_path}...")
                result = subprocess.run([
                    "aws", "ssm", "get-parameter",
                    "--name", ssm_path,
                    "--with-decryption",
                    "--output", "json"
                ], capture_output=True, text=True)
                
                if result.returncode != 0:
                    click.echo(f"Error: Parameter not found in AWS SSM or access denied.")
                    return
                
                # Parse the JSON response
                try:
                    response = json.loads(result.stdout)
                    parameter_value = response.get("Parameter", {}).get("Value", "")
                    
                    if not parameter_value:
                        click.echo("Error: Retrieved parameter has no value.")
                        return
                    
                    # Write to local .env.local file
                    with open(local_env_path, 'w') as file:
                        file.write(parameter_value)
                        
                    click.echo(f"Successfully downloaded .env.local from AWS SSM and saved to {local_env_path}")
                except json.JSONDecodeError:
                    click.echo("Error parsing AWS SSM response.")
            except Exception as e:
                click.echo(f"Error: {e}")
                
        else:
            # Default behavior without a command (local file management)
            if os.path.exists(local_env_path):
                click.echo(f"Found .env.local in current directory: {local_env_path}")
                
                if match:
                    # Extract the project root path
                    project_root = match.group(1)
                    
                    # Project name is the last directory in the path
                    project_name = os.path.basename(project_root)
                    org_name = os.path.basename(os.path.dirname(project_root))
                    
                    # Construct the storage path for the .env.local file
                    storage_dir = os.path.expanduser(f"~/toast/{org_name}/{project_name}")
                    storage_path = os.path.join(storage_dir, ".env.local")
                    
                    # Ensure the storage directory exists
                    if not os.path.exists(storage_dir):
                        os.makedirs(storage_dir)
                        click.echo(f"Created storage directory: {storage_dir}")
                    
                    # Copy the .env.local to the storage path
                    with open(local_env_path, 'r') as src_file:
                        content = src_file.read()
                    
                    with open(storage_path, 'w') as dst_file:
                        dst_file.write(content)
                        
                    click.echo(f"Stored .env.local file at: {storage_path}")
                else:
                    click.echo("Current directory is not in a recognized workspace structure.")
                    
            else:
                click.echo(".env.local not found in current directory.")
                
                if match:
                    # Extract the project root path
                    project_root = match.group(1)
                    
                    # Project name is the last directory in the path
                    project_name = os.path.basename(project_root)
                    org_name = os.path.basename(os.path.dirname(project_root))
                    
                    # Construct the storage path for the .env.local file
                    storage_dir = os.path.expanduser(f"~/toast/{org_name}/{project_name}")
                    storage_path = os.path.join(storage_dir, ".env.local")
                    
                    if os.path.exists(storage_path):
                        click.echo(f"Found stored .env.local at: {storage_path}")
                        click.echo("Use 'toast local down' to retrieve from AWS SSM or copy the file manually")
                    else:
                        click.echo(f"No stored .env.local found at: {storage_path}")
                else:
                    click.echo("Current directory is not in a recognized workspace structure.")