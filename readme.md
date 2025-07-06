# Minecraft on Fly.io

## Overview

This project lets you run a basic configurable PaperMC Minecraft server on Fly.io, with automated backups to Cloudflare R2, auto shutdown, and (almost) full configuration via environment variables.

Current configured version: 1.21.7, build 16.

https://fill-data.papermc.io/v1/objects/5554d04f7b72cf9776843d7d600dfa72062ad4e9991dbcf6d7d47bdd58cead9f/paper-1.21.7-16.jar

---

Using Fly's scale-to-zero features, this can actually be decenlty cost-effective for a managed solution (setting up a custom VPS would still be cheaper of course)

[Fly.io Pricing Calulator](https://fly.io/calculator?m=0_0_0_0_0&f=c&b=fra.100&a=no_none&r=shared_0_1_fra&t=10_100_5&u=0_1_100&g=1_performance_50_1_8192_fra_1024_10)

---

## 1. Configure Environment Variables

- Copy `.env.example` to `.env` and fill in all **required** values.
- Most configuration is controlled by environment variables.
- **The full list of supported variables is below.**  
  - Only the required variables need to be set; the rest are optional and can be set as needed.

---

## 2. Add Cloudflare R2 Access Keys

- Go to Cloudflare R2 dashboard [dash.cloudflare.com](https://dash.cloudflare.com/).
- Create an **Account API token** with Object Read & Write permissions for your bucket.
- Update these in your `.env`:
  ```
  RCLONE_CONFIG_R2_ACCESS_KEY_ID=your-access-key-id
  RCLONE_CONFIG_R2_SECRET_ACCESS_KEY=your-secret-access-key
  RCLONE_CONFIG_R2_ENDPOINT=https://your-accountid.r2.cloudflarestorage.com
  ```

---

## 3. Launch on Fly

- Install [flyctl](https://fly.io/docs/hands-on/install-flyctl/).
- Run `fly launch` and follow prompts (edit `fly.toml` as needed).
---

## 4. Add Fly Secrets

- Use `--stage` to avoid multiple restarts (this is currently the best way to add multiple secrets at once afaik):

```sh
grep -v '^#' .env | grep -v '^$' | sed '$d' | xargs -L 1 fly secrets set --stage
grep -v '^#' .env | grep -v '^$' | tail -n 1 | xargs fly secrets set
```
- This will add all secrets and trigger only one deploy/restart.

---

## Backups
- Backups are automatically created when the server shuts down using a bash trap in the `start.sh` script.

---

## Auto Shutdown
- Auto Shutdown is automatically enabled when the server starts using the `AutoShutdown` plugin, which by default shuts down the server after 5 minutes of player inactivity. This plugin can be changed using one of the following environment variables:

```env
AUTOSHUTDOWN_INITIAL_DELAY_SECONDS=60 - initial delay before triggering the countdown, to allow for player activity
AUTOSHUTDOWN_SHUTDOWN_DELAY_SECONDS=300 - default value (5 minutes)
AUTOSHUTDOWN_ENABLE_LOGGING=<true|false> - default value (true)
```

---

## RCON (internal only, no public port)

- SSH into the Fly VM
```sh
fly ssh console
```
- Run `mcrcon` to connect to the RCON server
```sh
mcrcon -H 127.0.0.1 -P 25575 -p strong-rcon-password
```
- See [mcrcon](https://github.com/Tiiffi/mcrcon) for more info.

---

## Supported Environment Variables

**Below is the complete list of supported variables. Only the required ones must be set; the rest are optional and can be set as needed.**

```env
# PaperMC download and JVM settings
JAR_URL=https://fill-data.papermc.io/v1/objects/your-paper-jar-url/paper-1.21.7-16.jar
JAR_FILE=paper.jar
JAVA_XMS=8G
JAVA_XMX=8G

# World and backup settings
WORLD_BASE=/server
WORLD_NAME=world
BACKUP_PATH=/server/backups

# rclone (Cloudflare R2) settings
RCLONE_REMOTE=r2:your-bucket-name
RCLONE_CONFIG_R2_TYPE=s3
RCLONE_CONFIG_R2_PROVIDER=Cloudflare
RCLONE_CONFIG_R2_ACCESS_KEY_ID=your-access-key-id
RCLONE_CONFIG_R2_SECRET_ACCESS_KEY=your-secret-access-key
RCLONE_CONFIG_R2_ENDPOINT=https://your-accountid.r2.cloudflarestorage.com
RCLONE_CONFIG_R2_NO_CHECK_BUCKET=true

# Minecraft server.properties settings
VIEW_DISTANCE=32
WHITE_LIST=true
SERVER_IP=0.0.0.0
MAX_PLAYERS=20
MOTD=A Minecraft Server
ENFORCE_WHITELIST=true
RCON_PASSWORD=strong-rcon-password
SIMULATION_DISTANCE=24
SPAWN_PROTECTION=0
DIFFICULTY=normal
ENABLE_RCON=true
RATE_LIMIT=512
PLAYER_IDLE_TIMEOUT=5

# Optional: Additional server.properties options
ACCEPTS_TRANSFERS=
ALLOW_FLIGHT=
ALLOW_NETHER=
BROADCAST_CONSOLE_TO_OPS=
BROADCAST_RCON_TO_OPS=
BUG_REPORT_LINK=
DEBUG=
ENABLE_COMMAND_BLOCK=
ENABLE_JMX_MONITORING=
ENABLE_QUERY=
ENABLE_STATUS=
ENFORCE_SECURE_PROFILE=
ENTITY_BROADCAST_RANGE_PERCENTAGE=
FORCE_GAMEMODE=
FUNCTION_PERMISSION_LEVEL=
GAMEMODE=
GENERATE_STRUCTURES=
GENERATOR_SETTINGS=
HARDCORE=
HIDE_ONLINE_PLAYERS=
INITIAL_DISABLED_PACKS=
INITIAL_ENABLED_PACKS=
LEVEL_NAME=
LEVEL_SEED=
LEVEL_TYPE=
LOG_IPS=
MAX_CHAINED_NEIGHBOR_UPDATES=
MAX_TICK_TIME=
MAX_WORLD_SIZE=
NETWORK_COMPRESSION_THRESHOLD=
ONLINE_MODE=
OP_PERMISSION_LEVEL=
PAUSE_WHEN_EMPTY_SECONDS=
PLAYER_IDLE_TIMEOUT=
PREVENT_PROXY_CONNECTIONS=
PVP=
QUERY_PORT=
RCON_PORT=
REGION_FILE_COMPRESSION=
REQUIRE_RESOURCE_PACK=
RESOURCE_PACK=
RESOURCE_PACK_ID=
RESOURCE_PACK_PROMPT=
RESOURCE_PACK_SHA1=
SERVER_PORT=
SPAWN_MONSTERS=
SYNC_CHUNK_WRITES=
TEXT_FILTERING_CONFIG=
TEXT_FILTERING_VERSION=
USE_NATIVE_TRANSPORT=

# Bukkit.yml options
BUKKIT_SETTINGS_ALLOW_END=
BUKKIT_SETTINGS_WARN_ON_OVERLOAD=
BUKKIT_SETTINGS_PERMISSIONS_FILE=
BUKKIT_SETTINGS_UPDATE_FOLDER=
BUKKIT_SETTINGS_PLUGIN_PROFILING=
BUKKIT_SETTINGS_CONNECTION_THROTTLE=
BUKKIT_SETTINGS_QUERY_PLUGINS=
BUKKIT_SETTINGS_DEPRECATED_VERBOSE=
BUKKIT_SETTINGS_SHUTDOWN_MESSAGE=
BUKKIT_SETTINGS_MINIMUM_API=
BUKKIT_SETTINGS_USE_MAP_COLOR_CACHE=
BUKKIT_SPAWN_LIMITS_MONSTERS=
BUKKIT_SPAWN_LIMITS_ANIMALS=
BUKKIT_SPAWN_LIMITS_WATER_ANIMALS=
BUKKIT_SPAWN_LIMITS_WATER_AMBIENT=
BUKKIT_SPAWN_LIMITS_WATER_UNDERGROUND_CREATURE=
BUKKIT_SPAWN_LIMITS_AXOLOTLS=
BUKKIT_SPAWN_LIMITS_AMBIENT=
BUKKIT_CHUNK_GC_PERIOD_IN_TICKS=
BUKKIT_TICKS_PER_ANIMAL_SPAWNS=
BUKKIT_TICKS_PER_MONSTER_SPAWNS=
BUKKIT_TICKS_PER_WATER_SPAWNS=
BUKKIT_TICKS_PER_WATER_AMBIENT_SPAWNS=
BUKKIT_TICKS_PER_WATER_UNDERGROUND_CREATURE_SPAWNS=
BUKKIT_TICKS_PER_AXOLOTL_SPAWNS=
BUKKIT_TICKS_PER_AMBIENT_SPAWNS=
BUKKIT_TICKS_PER_AUTOSAVE=
BUKKIT_ALIASES=

# Spigot.yml options
SPIGOT_MESSAGES_WHITELIST=
SPIGOT_MESSAGES_UNKNOWN_COMMAND=
SPIGOT_MESSAGES_SERVER_FULL=
SPIGOT_MESSAGES_OUTDATED_CLIENT=
SPIGOT_MESSAGES_OUTDATED_SERVER=
SPIGOT_MESSAGES_RESTART=
SPIGOT_SETTINGS_BUNGEECORD=
SPIGOT_SETTINGS_SAVE_USER_CACHE_ON_STOP_ONLY=
SPIGOT_SETTINGS_SAMPLE_COUNT=
SPIGOT_SETTINGS_PLAYER_SHUFFLE=
SPIGOT_SETTINGS_USER_CACHE_SIZE=
SPIGOT_SETTINGS_MOVED_WRONGLY_THRESHOLD=
SPIGOT_SETTINGS_MOVED_TOO_QUICKLY_MULTIPLIER=
SPIGOT_SETTINGS_TIMEOUT_TIME=
SPIGOT_SETTINGS_RESTART_ON_CRASH=
SPIGOT_SETTINGS_RESTART_SCRIPT=
SPIGOT_SETTINGS_NETTY_THREADS=
SPIGOT_SETTINGS_LOG_VILLAGER_DEATHS=
SPIGOT_SETTINGS_LOG_NAMED_DEATHS=
SPIGOT_SETTINGS_DEBUG=
SPIGOT_SETTINGS_ATTRIBUTE_MAXABSORPTION_MAX=
SPIGOT_SETTINGS_ATTRIBUTE_MAXHEALTH_MAX=
SPIGOT_SETTINGS_ATTRIBUTE_MOVEMENTSPEED_MAX=
SPIGOT_SETTINGS_ATTRIBUTE_ATTACKDAMAGE_MAX=
SPIGOT_ADVANCEMENTS_DISABLE_SAVING=
SPIGOT_WORLDSETTINGS_DEFAULT_BELOW_ZERO_GENERATION_IN_EXISTING_CHUNKS=
SPIGOT_WORLDSETTINGS_DEFAULT_VIEW_DISTANCE=
SPIGOT_WORLDSETTINGS_DEFAULT_SIMULATION_DISTANCE=
SPIGOT_WORLDSETTINGS_DEFAULT_THUNDER_CHANCE=
SPIGOT_WORLDSETTINGS_DEFAULT_MOB_SPAWN_RANGE=
SPIGOT_WORLDSETTINGS_DEFAULT_ITEM_DESPAWN_RATE=
SPIGOT_WORLDSETTINGS_DEFAULT_ARROW_DESPAWN_RATE=
SPIGOT_WORLDSETTINGS_DEFAULT_TRIDENT_DESPAWN_RATE=
SPIGOT_WORLDSETTINGS_DEFAULT_ZOMBIE_AGGRESSIVE_TOWARDS_VILLAGER=
SPIGOT_WORLDSETTINGS_DEFAULT_NERF_SPAWNER_MOBS=
SPIGOT_WORLDSETTINGS_DEFAULT_ENABLE_ZOMBIE_PIGMEN_PORTAL_SPAWNS=
SPIGOT_WORLDSETTINGS_DEFAULT_WITHER_SPAWN_SOUND_RADIUS=
SPIGOT_WORLDSETTINGS_DEFAULT_END_PORTAL_SOUND_RADIUS=
SPIGOT_WORLDSETTINGS_DEFAULT_HANGING_TICK_FREQUENCY=
SPIGOT_WORLDSETTINGS_DEFAULT_UNLOAD_FROZEN_CHUNKS=
SPIGOT_WORLDSETTINGS_DEFAULT_HOPPER_AMOUNT=
SPIGOT_WORLDSETTINGS_DEFAULT_HOPPER_CAN_LOAD_CHUNKS=
SPIGOT_WORLDSETTINGS_DEFAULT_DRAGON_DEATH_SOUND_RADIUS=
SPIGOT_WORLDSETTINGS_DEFAULT_VERBOSE=
SPIGOT_WORLDSETTINGS_DEFAULT_MAX_TNT_PER_TICK=
SPIGOT_PLAYERS_DISABLE_SAVING=
SPIGOT_STATS_DISABLE_SAVING=
SPIGOT_COMMANDS_TAB_COMPLETE=
SPIGOT_COMMANDS_SEND_NAMESPACED=
SPIGOT_COMMANDS_LOG=
SPIGOT_COMMANDS_SILENT_COMMANDBLOCK_CONSOLE=
SPIGOT_COMMANDS_ENABLE_SPAM_EXCLUSIONS=
SPIGOT_CONFIG_VERSION=

# AutoShutdown plugin config
AUTOSHUTDOWN_INITIAL_DELAY_SECONDS=
AUTOSHUTDOWN_SHUTDOWN_DELAY_SECONDS=
AUTOSHUTDOWN_ENABLE_LOGGING=
```

## References


- [Fly.io Documentation](https://fly.io/docs/)
- [Cloudflare R2 Documentation](https://developers.cloudflare.com/r2/)
- [PaperMC Documentation](https://docs.papermc.io/)
- [rclone Documentation](https://rclone.org/)
- [AutoShutdown Plugin](https://github.com/incogn1/AutoShutdown)
- [mcrcon](https://github.com/Tiiffi/mcrcon)

