import argparse
import sys
from typing import List, NamedTuple, Optional
from pathlib import Path

from fabric_cicd import FabricWorkspace, publish_all_items, unpublish_all_orphan_items


class DeploymentConfig(NamedTuple):
    """Configuration for Fabric workspace deployment."""
    workspace_id: str
    environment: str
    repository_directory: str
    item_types: Optional[List[str]]


def parse_arguments() -> DeploymentConfig:
    """Parse and validate command line arguments."""
    parser = argparse.ArgumentParser(
        description='Process Azure Pipeline arguments.')
    parser.add_argument('--workspace_id', type=str, required=True,
                        help='The ID of the target Fabric workspace')
    parser.add_argument('--environment', type=str, required=True,
                        choices=['test', 'prod'],
                        help='The target environment (test or prod)')
    parser.add_argument('--source_directory', type=str, required=True,
                        help='Path to the source directory containing Fabric items')
    parser.add_argument('--items_in_scope', type=str, required=False,
                        help='Comma-separated list of item types to process (optional - if not provided or empty, all item types will be processed)')

    args = parser.parse_args()

    # Validate arguments
    if not args.workspace_id:
        print("❌ Error: workspace_id is required!")
        sys.exit(1)

    # Environment validation is now handled by argparse choices
    if not args.environment:
        print("❌ Error: environment is required!")
        sys.exit(1)

    if not args.source_directory:
        print("❌ Error: source_directory is required!")
        sys.exit(1)

    # Parse and clean item types - handle None or empty string
    if args.items_in_scope and args.items_in_scope.strip():
        item_types = [item.strip()
                      for item in args.items_in_scope.split(",") if item.strip()]
        if not item_types:
            print("❌ Error: At least one item type must be specified in items_in_scope!")
            sys.exit(1)
    else:
        # If items_in_scope is not provided or empty, use None (deploy all items)
        item_types = None

    return DeploymentConfig(
        workspace_id=args.workspace_id,
        environment=args.environment,
        repository_directory=str(
            Path.cwd() / "workspaces" / args.source_directory),
        item_types=item_types
    )


def print_deployment_header(config: DeploymentConfig) -> None:
    """Print deployment welcome message and configuration details."""
    print("🚀 Starting Fabric Workspace Deployment...")
    print("=" * 50)
    print("📋 Processing deployment arguments...")
    print(f"🏢 Workspace ID: {config.workspace_id}")
    print(f"🌍 Environment: {config.environment}")
    print(f"📁 Repository Directory: {config.repository_directory}")
    items_display = ', '.join(config.item_types) if config.item_types else "All item types"
    print(f"📦 Items in Scope: {items_display}")
    print()


def create_workspace_config(config: DeploymentConfig) -> FabricWorkspace:
    """Create and return Fabric workspace configuration."""
    print("🔧 Creating Fabric workspace configuration...")
    try:
        target_workspace = FabricWorkspace(
            workspace_id=config.workspace_id,
            environment=config.environment,
            repository_directory=config.repository_directory,
            item_type_in_scope=config.item_types,
        )
        print("✅ Workspace configuration created successfully!")
        print()
        return target_workspace
    except Exception as e:
        print(f"❌ Error creating workspace configuration: {e}")
        sys.exit(1)


def deploy_items(workspace: FabricWorkspace) -> None:
    """Deploy all items to the workspace."""
    print("📤 Publishing all items to workspace...")
    try:
        publish_all_items(workspace)
        print("✅ Successfully published all items!")
        print()
    except Exception as e:
        print(f"❌ Error publishing items: {e}")
        sys.exit(1)


def cleanup_orphaned_items(workspace: FabricWorkspace) -> None:
    """Remove orphaned items from the workspace."""
    print("🧹 Cleaning up orphaned items...")
    try:
        unpublish_all_orphan_items(workspace)
        print("✅ Successfully removed orphaned items!")
        print()
    except Exception as e:
        print(f"❌ Error cleaning up orphaned items: {e}")
        sys.exit(1)


def print_completion_message() -> None:
    """Print deployment completion message."""
    print("🎉 Deployment completed successfully!")
    print("=" * 50)


def main() -> None:
    """Main deployment function."""
    # Parse arguments and configuration
    config = parse_arguments()

    # Print deployment information
    print_deployment_header(config)

    # Create workspace configuration
    workspace = create_workspace_config(config)

    # Execute deployment steps
    deploy_items(workspace)
    cleanup_orphaned_items(workspace)

    # Print completion message
    print_completion_message()


if __name__ == "__main__":
    main()
