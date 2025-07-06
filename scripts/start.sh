#!/bin/bash

# Backup on shutdown
trap '/backup.sh' EXIT

if [ -z "$JAR_URL" ]; then
  echo "JAR_URL not set"
  exit 1
fi

if [ ! -f "${JAR_FILE:-paper.jar}" ]; then
  curl -L -o "${JAR_FILE:-paper.jar}" "$JAR_URL"
fi

if [ ! -f eula.txt ]; then
  java -jar "${JAR_FILE:-paper.jar}" --nogui || true
fi
if ! grep -q 'eula=true' eula.txt 2>/dev/null; then
  echo "eula=true" > eula.txt
fi

if [ ! -f server.properties ]; then
  java -jar "${JAR_FILE:-paper.jar}" --nogui || true
fi

PLUGIN_DIR="plugins"
mkdir -p "$PLUGIN_DIR"

# Read plugins from the PLUGINS env variable, one per line or space
IFS=$'\n' read -rd '' -a plugin_entries <<<"$PLUGINS"

for entry in "${plugin_entries[@]}"; do
  # Skip empty lines
  [ -z "$entry" ] && continue

  if [[ "$entry" == *"|"* ]]; then
    PLUGIN_JAR="${entry%%|*}"
    PLUGIN_URL="${entry#*|}"
  else
    PLUGIN_URL="$entry"
    PLUGIN_JAR=$(basename "$PLUGIN_URL")
  fi

  if [ ! -f "$PLUGIN_DIR/$PLUGIN_JAR" ]; then
    echo "Downloading $PLUGIN_JAR from $PLUGIN_URL"
    curl -L -o "$PLUGIN_DIR/$PLUGIN_JAR" "$PLUGIN_URL"
  fi
done

# --- Helper: Set or Update a Property in server.properties ---
# Only updates if the corresponding environment variable is set.
set_prop() {
  key="$1"
  val="$2"
  grep -q "^$key=" server.properties && \
    sed -i "s|^$key=.*|$key=$val|" server.properties || \
    echo "$key=$val" >> server.properties
}

# --- Patch server.properties from Environment Variables ---
# For every property, if ENV VAR is set, update it; otherwise, leave as-is.

# List all server.properties options here, mapping ENV VAR to property key.
[ -n "$ACCEPTS_TRANSFERS" ]                && set_prop accepts-transfers "$ACCEPTS_TRANSFERS"
[ -n "$ALLOW_FLIGHT" ]                     && set_prop allow-flight "$ALLOW_FLIGHT"
[ -n "$ALLOW_NETHER" ]                     && set_prop allow-nether "$ALLOW_NETHER"
[ -n "$BROADCAST_CONSOLE_TO_OPS" ]         && set_prop broadcast-console-to-ops "$BROADCAST_CONSOLE_TO_OPS"
[ -n "$BROADCAST_RCON_TO_OPS" ]            && set_prop broadcast-rcon-to-ops "$BROADCAST_RCON_TO_OPS"
[ -n "$BUG_REPORT_LINK" ]                  && set_prop bug-report-link "$BUG_REPORT_LINK"
[ -n "$DEBUG" ]                            && set_prop debug "$DEBUG"
[ -n "$DIFFICULTY" ]                       && set_prop difficulty "$DIFFICULTY"
[ -n "$ENABLE_COMMAND_BLOCK" ]             && set_prop enable-command-block "$ENABLE_COMMAND_BLOCK"
[ -n "$ENABLE_JMX_MONITORING" ]            && set_prop enable-jmx-monitoring "$ENABLE_JMX_MONITORING"
[ -n "$ENABLE_QUERY" ]                     && set_prop enable-query "$ENABLE_QUERY"
[ -n "$ENABLE_RCON" ]                      && set_prop enable-rcon "$ENABLE_RCON"
[ -n "$ENABLE_STATUS" ]                    && set_prop enable-status "$ENABLE_STATUS"
[ -n "$ENFORCE_SECURE_PROFILE" ]           && set_prop enforce-secure-profile "$ENFORCE_SECURE_PROFILE"
[ -n "$ENFORCE_WHITELIST" ]                && set_prop enforce-whitelist "$ENFORCE_WHITELIST"
[ -n "$ENTITY_BROADCAST_RANGE_PERCENTAGE" ]&& set_prop entity-broadcast-range-percentage "$ENTITY_BROADCAST_RANGE_PERCENTAGE"
[ -n "$FORCE_GAMEMODE" ]                   && set_prop force-gamemode "$FORCE_GAMEMODE"
[ -n "$FUNCTION_PERMISSION_LEVEL" ]         && set_prop function-permission-level "$FUNCTION_PERMISSION_LEVEL"
[ -n "$GAMEMODE" ]                         && set_prop gamemode "$GAMEMODE"
[ -n "$GENERATE_STRUCTURES" ]              && set_prop generate-structures "$GENERATE_STRUCTURES"
[ -n "$GENERATOR_SETTINGS" ]                && set_prop generator-settings "$GENERATOR_SETTINGS"
[ -n "$HARDCORE" ]                         && set_prop hardcore "$HARDCORE"
[ -n "$HIDE_ONLINE_PLAYERS" ]              && set_prop hide-online-players "$HIDE_ONLINE_PLAYERS"
[ -n "$INITIAL_DISABLED_PACKS" ]           && set_prop initial-disabled-packs "$INITIAL_DISABLED_PACKS"
[ -n "$INITIAL_ENABLED_PACKS" ]            && set_prop initial-enabled-packs "$INITIAL_ENABLED_PACKS"
[ -n "$LEVEL_NAME" ]                       && set_prop level-name "$LEVEL_NAME"
[ -n "$LEVEL_SEED" ]                       && set_prop level-seed "$LEVEL_SEED"
[ -n "$LEVEL_TYPE" ]                       && set_prop level-type "$LEVEL_TYPE"
[ -n "$LOG_IPS" ]                          && set_prop log-ips "$LOG_IPS"
[ -n "$MAX_CHAINED_NEIGHBOR_UPDATES" ]     && set_prop max-chained-neighbor-updates "$MAX_CHAINED_NEIGHBOR_UPDATES"
[ -n "$MAX_PLAYERS" ]                      && set_prop max-players "$MAX_PLAYERS"
[ -n "$MAX_TICK_TIME" ]                    && set_prop max-tick-time "$MAX_TICK_TIME"
[ -n "$MAX_WORLD_SIZE" ]                   && set_prop max-world-size "$MAX_WORLD_SIZE"
[ -n "$MOTD" ]                             && set_prop motd "$MOTD"
[ -n "$NETWORK_COMPRESSION_THRESHOLD" ]    && set_prop network-compression-threshold "$NETWORK_COMPRESSION_THRESHOLD"
[ -n "$ONLINE_MODE" ]                      && set_prop online-mode "$ONLINE_MODE"
[ -n "$OP_PERMISSION_LEVEL" ]              && set_prop op-permission-level "$OP_PERMISSION_LEVEL"
[ -n "$PAUSE_WHEN_EMPTY_SECONDS" ]         && set_prop pause-when-empty-seconds "$PAUSE_WHEN_EMPTY_SECONDS"
[ -n "$PLAYER_IDLE_TIMEOUT" ]              && set_prop player-idle-timeout "$PLAYER_IDLE_TIMEOUT"
[ -n "$PREVENT_PROXY_CONNECTIONS" ]        && set_prop prevent-proxy-connections "$PREVENT_PROXY_CONNECTIONS"
[ -n "$PVP" ]                              && set_prop pvp "$PVP"
[ -n "$QUERY_PORT" ]                       && set_prop query.port "$QUERY_PORT"
[ -n "$RATE_LIMIT" ]                       && set_prop rate-limit "$RATE_LIMIT"
[ -n "$RCON_PASSWORD" ]                    && set_prop rcon.password "$RCON_PASSWORD"
[ -n "$RCON_PORT" ]                        && set_prop rcon.port "$RCON_PORT"
[ -n "$REGION_FILE_COMPRESSION" ]          && set_prop region-file-compression "$REGION_FILE_COMPRESSION"
[ -n "$REQUIRE_RESOURCE_PACK" ]            && set_prop require-resource-pack "$REQUIRE_RESOURCE_PACK"
[ -n "$RESOURCE_PACK" ]                    && set_prop resource-pack "$RESOURCE_PACK"
[ -n "$RESOURCE_PACK_ID" ]                 && set_prop resource-pack-id "$RESOURCE_PACK_ID"
[ -n "$RESOURCE_PACK_PROMPT" ]             && set_prop resource-pack-prompt "$RESOURCE_PACK_PROMPT"
[ -n "$RESOURCE_PACK_SHA1" ]               && set_prop resource-pack-sha1 "$RESOURCE_PACK_SHA1"
[ -n "$SERVER_IP" ]                        && set_prop server-ip "$SERVER_IP"
[ -n "$SERVER_PORT" ]                      && set_prop server-port "$SERVER_PORT"
[ -n "$SIMULATION_DISTANCE" ]              && set_prop simulation-distance "$SIMULATION_DISTANCE"
[ -n "$SPAWN_MONSTERS" ]                   && set_prop spawn-monsters "$SPAWN_MONSTERS"
[ -n "$SPAWN_PROTECTION" ]                 && set_prop spawn-protection "$SPAWN_PROTECTION"
[ -n "$SYNC_CHUNK_WRITES" ]                && set_prop sync-chunk-writes "$SYNC_CHUNK_WRITES"
[ -n "$TEXT_FILTERING_CONFIG" ]            && set_prop text-filtering-config "$TEXT_FILTERING_CONFIG"
[ -n "$TEXT_FILTERING_VERSION" ]           && set_prop text-filtering-version "$TEXT_FILTERING_VERSION"
[ -n "$USE_NATIVE_TRANSPORT" ]             && set_prop use-native-transport "$USE_NATIVE_TRANSPORT"
[ -n "$VIEW_DISTANCE" ]                    && set_prop view-distance "$VIEW_DISTANCE"
[ -n "$WHITE_LIST" ]                       && set_prop white-list "$WHITE_LIST"

# --- Patch bukkit.yml from Environment Variables ---
# Usage: set_bukkit <yaml_path> <env_var>
set_bukkit() {
  yaml_path="$1"
  env_var="$2"
  val="${!env_var}"
  if [ -n "$val" ]; then
    # Use yq if available, else fallback to sed (less robust)
    if command -v yq >/dev/null 2>&1; then
      yq -i ".$yaml_path = \"$val\"" bukkit.yml
    else
      key=$(echo "$yaml_path" | awk -F. '{print $NF}')
      sed -i "s|^\([[:space:]]*$key:\).*|\1 $val|" bukkit.yml
    fi
  fi
}

# Patch settings
set_bukkit "settings.allow-end" BUKKIT_SETTINGS_ALLOW_END
set_bukkit "settings.warn-on-overload" BUKKIT_SETTINGS_WARN_ON_OVERLOAD
set_bukkit "settings.permissions-file" BUKKIT_SETTINGS_PERMISSIONS_FILE
set_bukkit "settings.update-folder" BUKKIT_SETTINGS_UPDATE_FOLDER
set_bukkit "settings.plugin-profiling" BUKKIT_SETTINGS_PLUGIN_PROFILING
set_bukkit "settings.connection-throttle" BUKKIT_SETTINGS_CONNECTION_THROTTLE
set_bukkit "settings.query-plugins" BUKKIT_SETTINGS_QUERY_PLUGINS
set_bukkit "settings.deprecated-verbose" BUKKIT_SETTINGS_DEPRECATED_VERBOSE
set_bukkit "settings.shutdown-message" BUKKIT_SETTINGS_SHUTDOWN_MESSAGE
set_bukkit "settings.minimum-api" BUKKIT_SETTINGS_MINIMUM_API
set_bukkit "settings.use-map-color-cache" BUKKIT_SETTINGS_USE_MAP_COLOR_CACHE

# Patch spawn-limits
set_bukkit "spawn-limits.monsters" BUKKIT_SPAWN_LIMITS_MONSTERS
set_bukkit "spawn-limits.animals" BUKKIT_SPAWN_LIMITS_ANIMALS
set_bukkit "spawn-limits.water-animals" BUKKIT_SPAWN_LIMITS_WATER_ANIMALS
set_bukkit "spawn-limits.water-ambient" BUKKIT_SPAWN_LIMITS_WATER_AMBIENT
set_bukkit "spawn-limits.water-underground-creature" BUKKIT_SPAWN_LIMITS_WATER_UNDERGROUND_CREATURE
set_bukkit "spawn-limits.axolotls" BUKKIT_SPAWN_LIMITS_AXOLOTLS
set_bukkit "spawn-limits.ambient" BUKKIT_SPAWN_LIMITS_AMBIENT

# Patch chunk-gc
set_bukkit "chunk-gc.period-in-ticks" BUKKIT_CHUNK_GC_PERIOD_IN_TICKS

# Patch ticks-per
set_bukkit "ticks-per.animal-spawns" BUKKIT_TICKS_PER_ANIMAL_SPAWNS
set_bukkit "ticks-per.monster-spawns" BUKKIT_TICKS_PER_MONSTER_SPAWNS
set_bukkit "ticks-per.water-spawns" BUKKIT_TICKS_PER_WATER_SPAWNS
set_bukkit "ticks-per.water-ambient-spawns" BUKKIT_TICKS_PER_WATER_AMBIENT_SPAWNS
set_bukkit "ticks-per.water-underground-creature-spawns" BUKKIT_TICKS_PER_WATER_UNDERGROUND_CREATURE_SPAWNS
set_bukkit "ticks-per.axolotl-spawns" BUKKIT_TICKS_PER_AXOLOTL_SPAWNS
set_bukkit "ticks-per.ambient-spawns" BUKKIT_TICKS_PER_AMBIENT_SPAWNS
set_bukkit "ticks-per.autosave" BUKKIT_TICKS_PER_AUTOSAVE

# Patch aliases
set_bukkit "aliases" BUKKIT_ALIASES

# --- Patch spigot.yml from Environment Variables ---
# Usage: set_spigot <yaml_path> <env_var>
set_spigot() {
  yaml_path="$1"
  env_var="$2"
  val="${!env_var}"
  if [ -n "$val" ]; then
    if command -v yq >/dev/null 2>&1; then
      yq -i ".$yaml_path = \"$val\"" spigot.yml
    else
      key=$(echo "$yaml_path" | awk -F. '{print $NF}')
      sed -i "s|^\([[:space:]]*$key:\).*|\1 $val|" spigot.yml
    fi
  fi
}

# --- messages ---
set_spigot "messages.whitelist" SPIGOT_MESSAGES_WHITELIST
set_spigot "messages.unknown-command" SPIGOT_MESSAGES_UNKNOWN_COMMAND
set_spigot "messages.server-full" SPIGOT_MESSAGES_SERVER_FULL
set_spigot "messages.outdated-client" SPIGOT_MESSAGES_OUTDATED_CLIENT
set_spigot "messages.outdated-server" SPIGOT_MESSAGES_OUTDATED_SERVER
set_spigot "messages.restart" SPIGOT_MESSAGES_RESTART

# --- settings ---
set_spigot "settings.bungeecord" SPIGOT_SETTINGS_BUNGEECORD
set_spigot "settings.save-user-cache-on-stop-only" SPIGOT_SETTINGS_SAVE_USER_CACHE_ON_STOP_ONLY
set_spigot "settings.sample-count" SPIGOT_SETTINGS_SAMPLE_COUNT
set_spigot "settings.player-shuffle" SPIGOT_SETTINGS_PLAYER_SHUFFLE
set_spigot "settings.user-cache-size" SPIGOT_SETTINGS_USER_CACHE_SIZE
set_spigot "settings.moved-wrongly-threshold" SPIGOT_SETTINGS_MOVED_WRONGLY_THRESHOLD
set_spigot "settings.moved-too-quickly-multiplier" SPIGOT_SETTINGS_MOVED_TOO_QUICKLY_MULTIPLIER
set_spigot "settings.timeout-time" SPIGOT_SETTINGS_TIMEOUT_TIME
set_spigot "settings.restart-on-crash" SPIGOT_SETTINGS_RESTART_ON_CRASH
set_spigot "settings.restart-script" SPIGOT_SETTINGS_RESTART_SCRIPT
set_spigot "settings.netty-threads" SPIGOT_SETTINGS_NETTY_THREADS
set_spigot "settings.log-villager-deaths" SPIGOT_SETTINGS_LOG_VILLAGER_DEATHS
set_spigot "settings.log-named-deaths" SPIGOT_SETTINGS_LOG_NAMED_DEATHS
set_spigot "settings.debug" SPIGOT_SETTINGS_DEBUG

# --- settings.attribute ---
set_spigot "settings.attribute.maxAbsorption.max" SPIGOT_SETTINGS_ATTRIBUTE_MAXABSORPTION_MAX
set_spigot "settings.attribute.maxHealth.max" SPIGOT_SETTINGS_ATTRIBUTE_MAXHEALTH_MAX
set_spigot "settings.attribute.movementSpeed.max" SPIGOT_SETTINGS_ATTRIBUTE_MOVEMENTSPEED_MAX
set_spigot "settings.attribute.attackDamage.max" SPIGOT_SETTINGS_ATTRIBUTE_ATTACKDAMAGE_MAX

# --- advancements ---
set_spigot "advancements.disable-saving" SPIGOT_ADVANCEMENTS_DISABLE_SAVING
# (Skipping 'advancements.disabled' list for simplicity)

# --- world-settings.default (examples, add more as needed) ---
set_spigot "world-settings.default.below-zero-generation-in-existing-chunks" SPIGOT_WORLDSETTINGS_DEFAULT_BELOW_ZERO_GENERATION_IN_EXISTING_CHUNKS
set_spigot "world-settings.default.view-distance" SPIGOT_WORLDSETTINGS_DEFAULT_VIEW_DISTANCE
set_spigot "world-settings.default.simulation-distance" SPIGOT_WORLDSETTINGS_DEFAULT_SIMULATION_DISTANCE
set_spigot "world-settings.default.thunder-chance" SPIGOT_WORLDSETTINGS_DEFAULT_THUNDER_CHANCE
set_spigot "world-settings.default.mob-spawn-range" SPIGOT_WORLDSETTINGS_DEFAULT_MOB_SPAWN_RANGE
set_spigot "world-settings.default.item-despawn-rate" SPIGOT_WORLDSETTINGS_DEFAULT_ITEM_DESPAWN_RATE
set_spigot "world-settings.default.arrow-despawn-rate" SPIGOT_WORLDSETTINGS_DEFAULT_ARROW_DESPAWN_RATE
set_spigot "world-settings.default.trident-despawn-rate" SPIGOT_WORLDSETTINGS_DEFAULT_TRIDENT_DESPAWN_RATE
set_spigot "world-settings.default.zombie-aggressive-towards-villager" SPIGOT_WORLDSETTINGS_DEFAULT_ZOMBIE_AGGRESSIVE_TOWARDS_VILLAGER
set_spigot "world-settings.default.nerf-spawner-mobs" SPIGOT_WORLDSETTINGS_DEFAULT_NERF_SPAWNER_MOBS
set_spigot "world-settings.default.enable-zombie-pigmen-portal-spawns" SPIGOT_WORLDSETTINGS_DEFAULT_ENABLE_ZOMBIE_PIGMEN_PORTAL_SPAWNS
set_spigot "world-settings.default.wither-spawn-sound-radius" SPIGOT_WORLDSETTINGS_DEFAULT_WITHER_SPAWN_SOUND_RADIUS
set_spigot "world-settings.default.end-portal-sound-radius" SPIGOT_WORLDSETTINGS_DEFAULT_END_PORTAL_SOUND_RADIUS
set_spigot "world-settings.default.hanging-tick-frequency" SPIGOT_WORLDSETTINGS_DEFAULT_HANGING_TICK_FREQUENCY
set_spigot "world-settings.default.unload-frozen-chunks" SPIGOT_WORLDSETTINGS_DEFAULT_UNLOAD_FROZEN_CHUNKS
set_spigot "world-settings.default.hopper-amount" SPIGOT_WORLDSETTINGS_DEFAULT_HOPPER_AMOUNT
set_spigot "world-settings.default.hopper-can-load-chunks" SPIGOT_WORLDSETTINGS_DEFAULT_HOPPER_CAN_LOAD_CHUNKS
set_spigot "world-settings.default.dragon-death-sound-radius" SPIGOT_WORLDSETTINGS_DEFAULT_DRAGON_DEATH_SOUND_RADIUS
set_spigot "world-settings.default.verbose" SPIGOT_WORLDSETTINGS_DEFAULT_VERBOSE
set_spigot "world-settings.default.max-tnt-per-tick" SPIGOT_WORLDSETTINGS_DEFAULT_MAX_TNT_PER_TICK

# --- players ---
set_spigot "players.disable-saving" SPIGOT_PLAYERS_DISABLE_SAVING

# --- stats ---
set_spigot "stats.disable-saving" SPIGOT_STATS_DISABLE_SAVING
# (Skipping 'stats.forced-stats' map for simplicity)

# --- commands ---
set_spigot "commands.tab-complete" SPIGOT_COMMANDS_TAB_COMPLETE
set_spigot "commands.send-namespaced" SPIGOT_COMMANDS_SEND_NAMESPACED
set_spigot "commands.log" SPIGOT_COMMANDS_LOG
set_spigot "commands.silent-commandblock-console" SPIGOT_COMMANDS_SILENT_COMMANDBLOCK_CONSOLE
set_spigot "commands.enable-spam-exclusions" SPIGOT_COMMANDS_ENABLE_SPAM_EXCLUSIONS
# (Skipping 'commands.spam-exclusions' and 'commands.replace-commands' lists for simplicity)

# --- config-version ---
set_spigot "config-version" SPIGOT_CONFIG_VERSION

# --- Patch AutoShutdown config.yml from Environment Variables ---
# Usage: set_autoshutdown <yaml_path> <env_var>
set_autoshutdown() {
  yaml_path="$1"
  env_var="$2"
  val="${!env_var}"
  if [ -n "$val" ]; then
    if command -v yq >/dev/null 2>&1; then
      yq -i ".$yaml_path = \"$val\"" plugins/AutoShutdown/config.yml
    else
      key=$(echo "$yaml_path" | awk -F. '{print $NF}')
      sed -i "s|^\([[:space:]]*$key:\).*|\1 $val|" plugins/AutoShutdown/config.yml
    fi
  fi
}

set_autoshutdown "initial_delay_seconds" AUTOSHUTDOWN_INITIAL_DELAY_SECONDS
set_autoshutdown "shutdown_delay_seconds" AUTOSHUTDOWN_SHUTDOWN_DELAY_SECONDS
set_autoshutdown "enable_logging" AUTOSHUTDOWN_ENABLE_LOGGING

# --- Start the Minecraft Server ---
java -Xms"${JAVA_XMS:-4G}" -Xmx"${JAVA_XMX:-4G}" -jar "${JAR_FILE:-paper.jar}" --nogui
