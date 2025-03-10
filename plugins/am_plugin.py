#!/usr/bin/env python3

import click
import subprocess
from plugins.base_plugin import BasePlugin

class AmPlugin(BasePlugin):
    """Plugin for 'am' command - shows AWS caller identity."""

    name = "am"
    help = "Show AWS caller identity"

    @classmethod
    def execute(cls, **kwargs):
        try:
            result = subprocess.run(["aws", "sts", "get-caller-identity"], capture_output=True, text=True)
            if result.returncode == 0:
                formatted_json = subprocess.run(["jq", "-C", "."], input=result.stdout, capture_output=True, text=True)
                click.echo(formatted_json.stdout)
            else:
                click.echo("Error fetching AWS caller identity.")
        except Exception as e:
            click.echo(f"Error fetching AWS caller identity: {e}")
