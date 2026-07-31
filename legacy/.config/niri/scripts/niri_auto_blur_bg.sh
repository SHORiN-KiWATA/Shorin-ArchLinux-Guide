#!/bin/bash

# ==============================================================================
# 1. 配置区
# ==============================================================================
CACHE_DIR="$HOME/.cache/blur-wallpapers/auto-blur-bg"
LAST_CLEAR_FILE="/tmp/niri_last_clear_wallpaper"
PID_FILE="/tmp/niri_auto_blur.pid"
LINK_NAME="cache-niri-auto-blur-bg"

# --- 核心设置 ---
# 壁纸后端: "auto" (优先awww), "swww", "awww"
WALLPAPER_BACKEND="auto"

# --- 行为开关 ---
OVERVIEW_FORCE_CLEAR="false"
# 是否开启后台自动维护
AUTO_MAINTENANCE="true"
# 维护周期（秒）
MAINTENANCE_INTERVAL=1800

WALL_DIR="$HOME/Pictures/Wallpapers/"

# --- 缓存数量限制 ---
ORPHAN_CACHE_LIMIT=10

# --- 浮动窗口例外设置 ---
FLOAT_BYPASS_ENABLED="true"
FLOAT_BYPASS_THRESHOLD="1"

# --- 视觉参数 ---
BLUR_ARG="0x17"
ENABLE_DARK="false"
DARK_OPACITY="40%"
ANIM_TYPE="fade"
ANIM_DURATION="0.4"
WORK_SWITCH_DELAY="0.1"

mkdir -p "$CACHE_DIR"

# ==============================================================================
# 2. 后端检测与初始化
# ==============================================================================
detect_backend() {
    if [[ "$WALLPAPER_BACKEND" == "auto" ]]; then
        if command -v awww &>/dev/null; then
            WALLPAPER_BACKEND="awww"
        elif command -v swww &>/dev/null; then
            WALLPAPER_BACKEND="swww"
        else
            echo "Error: Neither 'awww' nor 'swww' found."
            exit 1
        fi
    fi
    
    # 验证选定的后端是否存在
    if ! command -v "$WALLPAPER_BACKEND" &>/dev/null; then
        echo "Error: Wallpaper backend '$WALLPAPER_BACKEND' not found."
        exit 1
    fi
}

detect_backend
# 构造设置壁纸的命令字串
SET_WALL_CMD="$WALLPAPER_BACKEND img --transition-type $ANIM_TYPE --transition-duration $ANIM_DURATION"

log() { echo -e "[$(date '+%H:%M:%S')] $1"; }
# log "Using backend: $WALLPAPER_BACKEND"

# ==============================================================================
# 3. 防止重复运行检查
# ==============================================================================
if [[ -f "$PID_FILE" ]]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Script already running (PID: $OLD_PID). Exiting."
        exit 1
    fi
fi
echo $$ > "$PID_FILE"

# ==============================================================================
# 4. 预计算与工具函数
# ==============================================================================
if [[ "$ENABLE_DARK" == "true" ]]; then
    SAFE_OPACITY="${DARK_OPACITY%\%}"
    FILE_PREFIX="auto-blur-dark-${BLUR_ARG}-${SAFE_OPACITY}-"
else
    FILE_PREFIX="auto-blur-pure-${BLUR_ARG}-"
fi

if [[ "$FLOAT_BYPASS_ENABLED" == "true" ]] && ! command -v jq &> /dev/null; then
    FLOAT_BYPASS_ENABLED="false"
fi

fetch_current_wall() {
    local raw_line
    # 动态调用 swww query 或 awww query
    read -r raw_line < <($WALLPAPER_BACKEND query 2>/dev/null)
    # 两个工具的输出格式通常都是 "Output: image: /path/..."
    if [[ "$raw_line" =~ image:[[:space:]]*([^[:space:]]+) ]]; then
        _RET_WALL="${BASH_REMATCH[1]}"
    else
        _RET_WALL=""
    fi
}

is_blur_filename() {
    [[ "$1" == "${FILE_PREFIX}"* || "$1" == auto-blur-* ]]
}

check_floating_bypass() {
    [[ "$FLOAT_BYPASS_ENABLED" != "true" ]] && return 1
    local workspaces_json=$(niri msg -j workspaces 2>/dev/null)
    local windows_json=$(niri msg -j windows 2>/dev/null)
    [[ -z "$workspaces_json" || -z "$windows_json" ]] && return 1

    local counts=$(jq -n -r --argjson ws "$workspaces_json" --argjson wins "$windows_json" '
        ($ws[] | select(.is_focused == true).id) as $focus_id |
        ($wins | map(select(.workspace_id == $focus_id))) as $my_wins |
        {
            total: ($my_wins | length),
            floating: ($my_wins | map(select(.is_floating == true)) | length),
            tiling: ($my_wins | map(select(.is_floating == false)) | length)
        } | "\(.total) \(.floating) \(.tiling)"
    ')
    read -r total floating tiling <<< "$counts"

    [[ "$total" -eq 0 ]] && return 0
    if [[ "$tiling" -eq 0 && "$floating" -le "$FLOAT_BYPASS_THRESHOLD" ]]; then
        log "Bypass: Only floating windows ($floating) -> Keep Clear"
        return 0
    fi
    return 1
}

# ==============================================================================
# X. [常驻后台] 自动维护守护进程
# ==============================================================================
MAINTENANCE_PID=""

start_maintenance_daemon() {
    [[ "$AUTO_MAINTENANCE" != "true" ]] && return

    log "Maintenance Daemon: 启动..."
    
    if [[ ! -d "$WALL_DIR" ]]; then
        log "Maintenance: 壁纸目录 $WALL_DIR 不存在，退出维护进程。"
        return
    fi

    (
        # 延迟启动，避免与主进程争抢 socket
        sleep 5

        # 0. 启动检查
        fetch_current_wall
        local current="$_RET_WALL"
        local current_base="${current##*/}"
        local current_target=""
        [[ -n "$current" ]] && current_target="$CACHE_DIR/${FILE_PREFIX}${current_base}"

        if [[ -n "$current" && ! -f "$current_target" && -f "$current" ]]; then
            if [[ "$ENABLE_DARK" == "true" ]]; then
                magick "$current" -blur "$BLUR_ARG" -fill black -colorize "$DARK_OPACITY" "$current_target"
            else
                magick "$current" -blur "$BLUR_ARG" "$current_target"
            fi
        fi

        # --- 进入无限循环，常驻后台 ---
        while true; do
            # A. 获取当前壁纸
            fetch_current_wall
            local loop_current="$_RET_WALL"
            local loop_current_target=""
            [[ -n "$loop_current" ]] && loop_current_target="$CACHE_DIR/${FILE_PREFIX}${loop_current##*/}"

            # B. 构建“白名单”
            declare -A active_wallpapers
            active_wallpapers=()
            
            while IFS= read -r -d '' file; do
                local basename="${file##*/}"
                active_wallpapers["$basename"]=1
            done < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0)

            # C. 扫描缓存目录
            local orphan_list=$(mktemp)
            local orphan_count=0
            
            while IFS= read -r -d '' cache_file; do
                local cache_name="${cache_file##*/}"
                local original_name="${cache_name#${FILE_PREFIX}}"
                
                if [[ -z "${active_wallpapers[$original_name]}" ]]; then
                    if [[ "$cache_name" != "${loop_current_target##*/}" ]]; then
                        echo "$cache_file" >> "$orphan_list"
                        orphan_count=$((orphan_count + 1))
                    fi
                fi
            done < <(find "$CACHE_DIR" -maxdepth 1 -name "${FILE_PREFIX}*" -print0)

            # D. 执行清理
            if [[ "$orphan_count" -gt "$ORPHAN_CACHE_LIMIT" ]]; then
                local delete_count=$((orphan_count - ORPHAN_CACHE_LIMIT))
                if [[ -s "$orphan_list" ]]; then
                    xargs -a "$orphan_list" ls -1tu | tail -n "$delete_count" | while read -r dead_file; do
                        rm -f "$dead_file"
                    done
                fi
            fi
            rm -f "$orphan_list"

            # E. 执行生成
            for img_name in "${!active_wallpapers[@]}"; do
                local img="${WALL_DIR}/${img_name}"
                local target="$CACHE_DIR/${FILE_PREFIX}${img_name}"

                if [[ -f "$target" ]]; then continue; fi

                if [[ -f "$img" ]]; then
                    if [[ "$ENABLE_DARK" == "true" ]]; then
                        magick "$img" -blur "$BLUR_ARG" -fill black -colorize "$DARK_OPACITY" "$target"
                    else
                        magick "$img" -blur "$BLUR_ARG" "$target"
                    fi
                fi
            done
            
            # F. 休眠
            sleep "$MAINTENANCE_INTERVAL"
        done
    ) & 
    
    MAINTENANCE_PID=$!
}

# ==============================================================================
# 5. 核心状态管理
# ==============================================================================
CURRENT_STATE=-1 
IS_OVERVIEW=false
DEBOUNCE_PID=""
_RET_WALL=""

cleanup() {
    rm -f "$PID_FILE"
    [[ -n "$DEBOUNCE_PID" ]] && kill "$DEBOUNCE_PID" 2>/dev/null
    
    if [[ -n "$MAINTENANCE_PID" ]]; then
        kill "$MAINTENANCE_PID" 2>/dev/null
    fi

    fetch_current_wall
    local cname="${_RET_WALL##*/}"
    if is_blur_filename "$cname" && [[ -f "$LAST_CLEAR_FILE" ]]; then
        local original=$(<"$LAST_CLEAR_FILE")
        # 退出时恢复无模糊状态，使用后端命令但无过渡
        [[ -f "$original" ]] && $WALLPAPER_BACKEND img "$original" --transition-type none
    fi
    exit 0
}
trap cleanup EXIT SIGINT SIGTERM

do_restore_task() {
    [[ ! -f "$LAST_CLEAR_FILE" ]] && return
    local target=$(<"$LAST_CLEAR_FILE")
    [[ ! -f "$target" ]] && return
    fetch_current_wall
    local cname="${_RET_WALL##*/}"
    if is_blur_filename "$cname"; then
        $SET_WALL_CMD "$target"
    fi
}

switch_to_clear() {
    local mode="$1"
    [[ "$CURRENT_STATE" -eq 0 ]] && return
    [[ -n "$DEBOUNCE_PID" ]] && kill "$DEBOUNCE_PID" 2>/dev/null && DEBOUNCE_PID=""

    if [[ "$mode" == "delay" ]]; then
        ( sleep "$WORK_SWITCH_DELAY"; do_restore_task ) &
        DEBOUNCE_PID=$!
    else
        do_restore_task
    fi
    CURRENT_STATE=0
}

switch_to_blur() {
    [[ -n "$DEBOUNCE_PID" ]] && kill "$DEBOUNCE_PID" 2>/dev/null && DEBOUNCE_PID=""
    if check_floating_bypass; then switch_to_clear "noderect"; return; fi

    fetch_current_wall
    local current="$_RET_WALL"
    [[ -z "$current" ]] && return
    local current_name="${current##*/}"

    if [[ "$current_name" == "${FILE_PREFIX}"* ]]; then
        [[ "$CURRENT_STATE" -ne 1 ]] && CURRENT_STATE=1
        return
    fi
    CURRENT_STATE=1

    if ! is_blur_filename "$current_name" && [[ "$current_name" != blur-dark-* ]]; then
        echo "$current" > "$LAST_CLEAR_FILE"
        local link_path="${current%/*}/$LINK_NAME"
        ln -sfn "$CACHE_DIR" "$link_path" 2>/dev/null
    fi

    [[ ! -f "$LAST_CLEAR_FILE" ]] && return
    local source_wall=$(<"$LAST_CLEAR_FILE")
    local target_blur="$CACHE_DIR/${FILE_PREFIX}${source_wall##*/}"

    if [[ ! -f "$target_blur" ]]; then
        if [[ "$ENABLE_DARK" == "true" ]]; then
            magick "$source_wall" -blur "$BLUR_ARG" -fill black -colorize "$DARK_OPACITY" "$target_blur"
        else
            magick "$source_wall" -blur "$BLUR_ARG" "$target_blur"
        fi
    else
        touch -a "$target_blur"
    fi

    $SET_WALL_CMD "$target_blur" &
}

force_check_state() {
    local niri_out=$(niri msg focused-window 2>&1)
    if [[ "$niri_out" == *"No window"* ]]; then
        [[ "$1" == "true" ]] && switch_to_clear "delay" || switch_to_clear "noderect"
    else
        switch_to_blur
    fi
}

# ==============================================================================
# 6. 主循环
# ==============================================================================
log "Daemon Started (PID: $$) using backend: $WALLPAPER_BACKEND"
start_maintenance_daemon
force_check_state "false"

niri msg event-stream | grep --line-buffered -E "^(Window|Workspace|Overview)" | while read -r line; do
    case "$line" in
        *"Window opened"*)              switch_to_blur ;;
        *"Window closed"*)              force_check_state "false" ;;
        *"Window focus changed: None"*) switch_to_clear "noderect" ;;
        *"Window focus changed: Some"*) switch_to_blur ;;
        *"Workspace focused"*)          [[ "$IS_OVERVIEW" == "false" ]] && force_check_state "true" ;;
        *"Overview toggled: true"*)     IS_OVERVIEW=true; [[ "$OVERVIEW_FORCE_CLEAR" == "true" ]] && switch_to_clear "noderect" ;;
        *"Overview toggled: false"*)    IS_OVERVIEW=false; force_check_state "false" ;;
        *"active window changed to Some"*) [[ "$IS_OVERVIEW" == "true" && "$OVERVIEW_FORCE_CLEAR" == "false" ]] && switch_to_blur ;;
        *"active window changed to None"*) [[ "$IS_OVERVIEW" == "true" && "$OVERVIEW_FORCE_CLEAR" == "false" ]] && switch_to_clear "noderect" ;;
    esac
done
