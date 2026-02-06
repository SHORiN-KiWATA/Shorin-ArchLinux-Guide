# 脚本功能：
# 从随机老婆图片生成 API 下载图片并使用 Fastfetch 展示。
# 特性：支持 NSFW 模式，支持自动补货，支持阅后即焚防止缓存爆炸。

function f
    # ================= 配置区域 =================
    
    # [开关] 阅后即焚模式
    # true  = 运行后强力清空 Fastfetch 的图片缓存（推荐，防止缓存目录无限膨胀）
    # false = 保留缓存（注意：这会导致 ~/.cache/fastfetch/images/ 占用越来越大）
    set -l CLEAN_CACHE_MODE true
    
    # 每次补货下载多少张
    set -l DOWNLOAD_BATCH_SIZE 10
    # 最大库存上限
    set -l MAX_CACHE_LIMIT 100
    # 库存少于多少张时开始补货
    set -l MIN_TRIGGER_LIMIT 60
    
    # ===========================================
    
    # --- 0. 参数解析与模式设置 ---
    
    set -l NSFW_MODE false
    # 检查环境变量
    if test "$NSFW" = "1"
        set NSFW_MODE true
    end
    
    set -l ARGS_FOR_FASTFETCH
    for arg in $argv
        if test "$arg" = "--nsfw"
            set NSFW_MODE true
        else
            set -a ARGS_FOR_FASTFETCH $arg
        end
    end
    
    # --- 1. 目录配置 ---
    
    # 根据模式区分缓存目录和锁文件
    set -l CACHE_DIR
    set -l LOCK_FILE
    if test "$NSFW_MODE" = true
        set CACHE_DIR "$HOME/.cache/fastfetch_waifu_nsfw"
        set LOCK_FILE "/tmp/fastfetch_waifu_nsfw.lock"
    else
        set CACHE_DIR "$HOME/.cache/fastfetch_waifu"
        set LOCK_FILE "/tmp/fastfetch_waifu.lock"
    end
    
    mkdir -p "$CACHE_DIR"
    
    # --- 2. 核心函数 ---
    
    function get_random_url -V NSFW_MODE
        set -l TIMEOUT --connect-timeout 5 --max-time 15
        set -l RAND (math (random) % 3 + 1)
        
        if test "$NSFW_MODE" = true
            # === NSFW API ===
            switch $RAND
                case 1
                    curl -s $TIMEOUT "https://api.waifu.im/search?included_tags=waifu&is_nsfw=true" | jq -r '.images[0].url'
                case 2
                    curl -s $TIMEOUT "https://api.waifu.pics/nsfw/waifu" | jq -r '.url'
                case 3
                    curl -s $TIMEOUT "https://api.waifu.pics/nsfw/neko" | jq -r '.url'
            end
        else
            # === SFW (正常) API ===
            switch $RAND
                case 1
                    curl -s $TIMEOUT "https://api.waifu.im/search?included_tags=waifu&is_nsfw=false" | jq -r '.images[0].url'
                case 2
                    curl -s $TIMEOUT "https://nekos.best/api/v2/waifu" | jq -r '.results[0].url'
                case 3
                    curl -s $TIMEOUT "https://api.waifu.pics/sfw/waifu" | jq -r '.url'
            end
        end
    end
    
    function download_one_image -V CACHE_DIR
        set -l URL (get_random_url)
        if string match -qr "^http" -- "$URL"
            # 使用带时间戳的随机文件名
            set -l FILENAME "waifu_"(date +%s%N)"_"(random)".jpg"
            set -l TARGET_PATH "$CACHE_DIR/$FILENAME"
            
            curl -s -L --connect-timeout 5 --max-time 15 -o "$TARGET_PATH" "$URL"
            
            # 简单校验
            if test -s "$TARGET_PATH"
                if command -v file >/dev/null 2>&1
                    if not file --mime-type "$TARGET_PATH" | grep -q "image/"
                        rm -f "$TARGET_PATH"
                    end
                end
            else
                rm -f "$TARGET_PATH"
            end
        end
    end
    
    function background_job -V CACHE_DIR -V LOCK_FILE -V MIN_TRIGGER_LIMIT -V DOWNLOAD_BATCH_SIZE -V MAX_CACHE_LIMIT -V NSFW_MODE
        # 导出函数定义
        set -l get_random_url_def (functions get_random_url | string collect)
        set -l download_one_image_def (functions download_one_image | string collect)
        
        fish -c "
            # 重新定义需要的函数
            $get_random_url_def
            $download_one_image_def
            
            # 使用 flock 防止并发
            flock -n 200 || exit 1
            
            # 导入变量
            set CACHE_DIR '$CACHE_DIR'
            set NSFW_MODE '$NSFW_MODE'
            
            # 1. 补货检查
            set CURRENT_COUNT (find \$CACHE_DIR -maxdepth 1 -name '*.jpg' 2>/dev/null | wc -l)
            
            if test \$CURRENT_COUNT -lt $MIN_TRIGGER_LIMIT
                for i in (seq 1 $DOWNLOAD_BATCH_SIZE)
                    download_one_image
                    sleep 0.5
                end
            end
            
            # 2. 清理过多库存
            set FINAL_COUNT (find \$CACHE_DIR -maxdepth 1 -name '*.jpg' 2>/dev/null | wc -l)
            if test \$FINAL_COUNT -gt $MAX_CACHE_LIMIT
                set DELETE_START_LINE (math $MAX_CACHE_LIMIT + 1)
                ls -tp \$CACHE_DIR/*.jpg 2>/dev/null | tail -n +\$DELETE_START_LINE | xargs -I {} rm -- '{}'
            end
        " 200>"$LOCK_FILE" &
    end
    
    # --- 3. 主程序逻辑 ---
    
    set -l FILES $CACHE_DIR/*.jpg
    set -l NUM_FILES (count $FILES)
    
    # fish 中如果没有匹配文件，会返回原始模式字符串，需要检查
    if test "$NUM_FILES" -eq 1; and not test -f "$FILES[1]"
        set NUM_FILES 0
        set FILES
    end
    
    set -l SELECTED_IMG ""
    
    if test "$NUM_FILES" -gt 0
        # 有库存，随机选一张
        set -l RAND_INDEX (math (random) % $NUM_FILES + 1)
        set SELECTED_IMG "$FILES[$RAND_INDEX]"
        
        # 后台补货
        background_job >/dev/null 2>&1
    else
        # 没库存，提示语更改
        echo "主人，库存不够啦！正在去搬运新的老婆图片，请稍等哦..."
        download_one_image
        
        set FILES $CACHE_DIR/*.jpg
        if test -f "$FILES[1]"
            set SELECTED_IMG "$FILES[1]"
            background_job >/dev/null 2>&1
        end
    end
    
    # 运行 Fastfetch
    if test -n "$SELECTED_IMG"; and test -f "$SELECTED_IMG"
        # 显示图片
        fastfetch --logo "$SELECTED_IMG" --logo-preserve-aspect-ratio true $ARGS_FOR_FASTFETCH
        
        # 检查是否开启"阅后即焚"缓存清理
        if test "$CLEAN_CACHE_MODE" = true
            # 删除原图
            rm -f "$SELECTED_IMG"
            # 强力清除 Fastfetch 生成的转码缓存，防止磁盘爆炸
            rm -rf "$HOME/.cache/fastfetch/images"
        end
    else
        # 失败提示语更改
        echo "呜呜... 图片下载失败了，这次只能先显示默认的 Logo 啦 QAQ"
        fastfetch $ARGS_FOR_FASTFETCH
    end
end

function fnsfw
    f --nsfw
end