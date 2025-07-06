#!/bin/bash
WORLD_BASE="${WORLD_BASE:-/server}"
WORLD_NAME="${WORLD_NAME:-world}"
BACKUP_PATH="${BACKUP_PATH:-/data/backups}"
RCLONE_REMOTE="${RCLONE_REMOTE:?RCLONE_REMOTE not set}"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

WORLDS=(
  "$WORLD_NAME"
  "${WORLD_NAME}_nether"
  "${WORLD_NAME}_the_end"
)

mkdir -p "$BACKUP_PATH"

TAR_ARGS=()
for w in "${WORLDS[@]}"; do
  [ -d "$WORLD_BASE/$w" ] && TAR_ARGS+=("$w")
done

if [ ${#TAR_ARGS[@]} -eq 0 ]; then
  echo "No world directories found to backup."
  exit 0
fi

cd "$WORLD_BASE"
tar -czf "$BACKUP_PATH/${WORLD_NAME}s-$TIMESTAMP.tar.gz" "${TAR_ARGS[@]}"

echo "Backing up worlds to $RCLONE_REMOTE..."
rclone copy "$BACKUP_PATH/${WORLD_NAME}s-$TIMESTAMP.tar.gz" "$RCLONE_REMOTE"

echo "Cleaning up old backups..."
find "$BACKUP_PATH" -type f -mtime +3 -delete
rclone delete "$RCLONE_REMOTE" --min-age 3d
