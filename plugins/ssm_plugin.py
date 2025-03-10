#!/usr/bin/env python3

import click
from plugins.base_plugin import BasePlugin

class SsmPlugin(BasePlugin):
    """Plugin for 'ssm' command - runs SSM commands."""

    name = "ssm"
    help = "Run AWS SSM commands"

    @classmethod
    def execute(cls, **kwargs):
        click.echo("Running SSM command")
