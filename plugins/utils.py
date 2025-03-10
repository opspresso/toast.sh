#!/usr/bin/env python3

import subprocess
import click

def select_from_list(options, prompt="Select an option"):
    try:
        fzf_proc = subprocess.run(["fzf", "--height=15", "--reverse", "--border", "--prompt", prompt+": "], input="\n".join(options), capture_output=True, text=True)
        return fzf_proc.stdout.strip()
    except Exception as e:
        click.echo(f"Error selecting from list: {e}")
        return None
