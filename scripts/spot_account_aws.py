#!/usr/bin/env python3

import click
import json
import sys
import boto3

from botocore.exceptions import ClientError
from spotinst_sdk2 import SpotinstSession


@click.group()
@click.pass_context
def cli(ctx, *args, **kwargs):
    ctx.obj = {}


@cli.command()
@click.argument('name', )
@click.option(
    '--token',
    required=True,
    help='Spotinst Token'
)
@click.pass_context
def create(ctx, *args, **kwargs):
    """Create a new Spot Account"""
    session = SpotinstSession(auth_token=kwargs.get('token'))
    ctx.obj['client'] = session.client("admin")
    result = ctx.obj['client'].create_account(kwargs.get('name'))
    click.echo(json.dumps(result))


@cli.command()
@click.argument('account-id')
@click.option(
    '--token',
    required=True,
    help='Spotinst Token'
)
@click.argument('random-string')
@click.pass_context
def delete(ctx, *args, **kwargs):
    """Delete a Spot Account"""
    session = SpotinstSession(auth_token=kwargs.get('token'))
    ctx.obj['client'] = session.client("admin")
    result = ctx.obj['client'].delete_account(kwargs.get('account_id'))
    client = boto3.client('ssm')
    try:
        client.delete_parameter(Name="Spot-External-ID-" + str(kwargs.get('random_string')))
    except ClientError as e:
        print(e)
    click.echo(json.dumps(result))


@cli.command()
@click.argument('account-id')
@click.option(
    '--token',
    required=True,
    help='Spotinst Token'
)
@click.pass_context
def create_external_id(ctx, *args, **kwargs):
    """Generate the Spot External ID for Spot Account connection"""
    input_json = sys.stdin.read()
    input_dict = json.loads(input_json)
    if input_dict.get('cloud_provider'):
        fail_string = {'external_id': ''}
        click.echo(json.dumps(fail_string))
    else:
        name = "Spot-External-ID-" + str(input_dict.get('random_string'))
        session = SpotinstSession(auth_token=kwargs.get('token'))
        ctx.obj['client2'] = session.client("setup_aws")
        ctx.obj['client2'].account_id = kwargs.get('account_id')
        result = ctx.obj['client2'].create_external_id()
        external_id = result["external_id"]
        try:
            client = boto3.client('ssm')
            client.put_parameter(Name=name, Value=external_id, Type='String', Tier='Standard',
                                 Overwrite=True)
        except ClientError as e:
            sys.exit(e)
        result = {'external_id': external_id}
        click.echo(json.dumps(result))


@cli.command()
@click.argument('account-id')
@click.argument('role-arn')
@click.option(
    '--token',
    required=True,
    help='Spotinst Token'
)
@click.pass_context
def set_cloud_credentials(ctx, *args, **kwargs):
    """Set AWS ROLE ARN to Spot Account"""
    session = SpotinstSession(auth_token=kwargs.get('token'))
    ctx.obj['client2'] = session.client("setup_aws")
    ctx.obj['client2'].account_id = kwargs.get('account_id')
    result = ctx.obj['client2'].set_credentials(iam_role=kwargs.get('role_arn'))
    click.echo(json.dumps(result))


@cli.command()
@click.option(
    '--filter',
    required=False,
    help='Return matching records. Syntax: key=value'
)
@click.option(
    '--attr',
    required=False,
    help='Return only the raw value of a single attribute'
)
@click.option(
    '--token',
    required=True,
    help='Spotinst Token'
)
@click.pass_context
def get(ctx, *args, **kwargs):
    """Returns ONLY the first match"""
    session = SpotinstSession(auth_token=kwargs.get('token'))
    ctx.obj['client'] = session.client("admin")
    result = ctx.obj['client'].get_accounts()
    if kwargs.get('filter'):
        k, v = kwargs.get('filter').split('=')
        result = [x for x in result if x[k] == v]
    if kwargs.get('attr'):
        if result:
            result = result[0].get(kwargs.get('attr'))
            click.echo(result)
        else:
            fail_string = {'account_id': '', 'organization_id': ''}
            click.echo(json.dumps(fail_string))
    else:
        if result:
            click.echo(json.dumps(result[0]))
        else:
            fail_string = {'account_id': '', 'organization_id': ''}
            click.echo(json.dumps(fail_string))


if __name__ == "__main__":
    cli()
