#!/usr/bin/env python3

import click
from plugins.base_plugin import BasePlugin

class UpdatePlugin(BasePlugin):
    """Plugin for 'update' command - updates CLI tool."""

    name = "update"
    help = "Update CLI tool"

    @classmethod
    def execute(cls, **kwargs):
        click.echo("Updating CLI tool")
