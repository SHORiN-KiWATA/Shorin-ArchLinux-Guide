#!/usr/bin/env bash

# ==============================================================================
# PCI-E Passthrough & HugePages Dynamic Switcher
# Features: Hardware Radar / Hot-Swap / 1GB->2MB Fallback / Process Guard
# ==============================================================================

set -euo pipefail

trap 'printf "\033[?25h"' EXIT

# --- Configuration ---
readonly VFIO_CONF="/etc/modprobe.d/vfio.conf"
readonly HUGEPAGE_CONF="/etc/sysctl.d/40-hugepage.conf"
readonly TARGET_HUGEPAGES_GB=16

# --- Colors ---
readonly C_BOLD='\033[1m'
readonly C_GREEN='\033[1;32m'
readonly C_RED='\033[1;31m'
readonly C_YELLOW='\033[1;33m'
readonly C_CYAN='\033[1;36m'
readonly C_NC='\033[0m'

# --- Globals ---
declare -a NVIDIA_PCI_LIST=()
declare -a NVIDIA_HWID_LIST=()
VFIO_IDS_STR=""
VGA_PCI_ID=""

check_root() {
    if [[ $EUID -ne 0 ]]; then
        printf "\n${C_YELLOW}[INFO] 检测到当前非 Root，正在请求 sudo 提权...${C_NC}\n"

        if ! command -v sudo >/dev/null 2>&1; then
            printf "\n${C_RED}[ERROR] 未找到 sudo，无法自动提权。${C_NC}\n\n"
            exit 1
        fi

        local cmd="$0"
        if [[ "$cmd" != */* ]]; then
            local local_cmd="./$cmd"
            if [[ -f "$local_cmd" ]]; then
                cmd="$local_cmd"
            else
                cmd="$(command -v -- "$cmd" || true)"
            fi
        fi
        if [[ -z "$cmd" ]]; then
            printf "\n${C_RED}[ERROR] 无法在当前目录或当前 PATH 中定位脚本，自动提权失败。${C_NC}\n\n"
            exit 1
        fi

        if [[ "$cmd" == ./* && ! -x "$cmd" ]]; then
            exec sudo -- bash "$cmd" "$@"
        fi

        exec sudo -- "$cmd" "$@"
    fi
}

detect_nvidia_gpu() {
    printf "${C_CYAN}[INFO] 正在扫描 NVIDIA 显卡及其关联设备...${C_NC}\n"

    local vga_dev
    vga_dev=$(lspci -D -nn | grep -i 'NVIDIA' | grep -E 'VGA|3D' | head -n 1 | awk '{print $1}' || true)

    if [[ -z "$vga_dev" ]]; then
        printf "\n${C_RED}[ERROR] 在 PCI 总线上未检测到 NVIDIA 显卡。${C_NC}\n\n"
        exit 1
    fi

    VGA_PCI_ID="$vga_dev"
    local pci_prefix="${vga_dev%.*}"

    NVIDIA_PCI_LIST=()
    NVIDIA_HWID_LIST=()

    for dev_path in /sys/bus/pci/devices/${pci_prefix}.*; do
        if [[ -d "$dev_path" ]]; then
            local pci_id=$(basename "$dev_path")
            NVIDIA_PCI_LIST+=("$pci_id")
            
            local vendor=$(cat "$dev_path/vendor")
            local device=$(cat "$dev_path/device")
            NVIDIA_HWID_LIST+=("${vendor#0x}:${device#0x}")
        fi
    done

    VFIO_IDS_STR=$(IFS=,; echo "${NVIDIA_HWID_LIST[*]}")
}

get_running_mode() {
    if [[ -z "$VGA_PCI_ID" || ! -d "/sys/bus/pci/devices/${VGA_PCI_ID}" ]]; then
        echo "脱机 / 未识别"
        return
    fi
    local driver
    driver=$(readlink "/sys/bus/pci/devices/${VGA_PCI_ID}/driver" | awk -F'/' '{print $NF}' || true)
    
    if [[ "$driver" == "vfio-pci" ]]; then
        echo "VFIO 直通隔离"
    elif [[ "$driver" == "nvidia" || "$driver" == "nouveau" ]]; then
        echo "原生 NVIDIA"
    else
        echo "游离 / 未绑定"
    fi
}

get_configured_mode() {
    if [[ ! -f "$VFIO_CONF" ]] || grep -q "^#" "$VFIO_CONF" || ! grep -q "options vfio-pci" "$VFIO_CONF"; then
        echo "原生 NVIDIA"
    else
        echo "VFIO 直通隔离"
    fi
}

show_status() {
    printf "\n"
    printf "  +------------------------------------------------------\n"
    printf "  |  ${C_BOLD}系统状态观测面板${C_NC}\n"
    printf "  +------------------------------------------------------\n"
    printf "  |  目标 PCI 设备集群 : ${C_CYAN}%s${C_NC}\n" "${NVIDIA_PCI_LIST[*]}"
    printf "  |  当前动态运行状态  : ${C_GREEN}%s${C_NC}\n" "$(get_running_mode)"
    printf "  |  下次冷启动状态    : ${C_GREEN}%s${C_NC}\n" "$(get_configured_mode)"
    printf "  +------------------------------------------------------\n\n"
}

allocate_hugepages() {
    printf "${C_CYAN}[INFO] 正在清理缓存并整理内存碎片...${C_NC}\n"
    sync
    echo 3 > /proc/sys/vm/drop_caches
    echo 1 > /proc/sys/vm/compact_memory
    sleep 2

    printf "${C_CYAN}[INFO] 正在尝试分配 %sGB 的 1GB 内存大页...${C_NC}\n" "$TARGET_HUGEPAGES_GB"
    echo "$TARGET_HUGEPAGES_GB" > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages 2>/dev/null || true
    local allocated_1g=$(cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages 2>/dev/null || echo "0")

    if [[ "$allocated_1g" -eq "$TARGET_HUGEPAGES_GB" ]]; then
        action_summary+=("1GB 大页分配成功 (已锁定: ${allocated_1g} 页)")
    else
        printf "${C_YELLOW}[WARN] 1GB 大页分配失败。仅获取到 %s 页。${C_NC}\n" "$allocated_1g"
        printf "${C_YELLOW}[WARN] 正在降级使用 2MB 大页分配策略。${C_NC}\n"
        
        echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages 2>/dev/null || true
        
        local target_2m=$((TARGET_HUGEPAGES_GB * 512))
        sysctl -w vm.nr_hugepages=${target_2m} &>/dev/null
        local allocated_2m=$(cat /proc/sys/vm/nr_hugepages 2>/dev/null || echo "0")
        action_summary+=("已降级并锁定 2MB 大页 (当前分配: ${allocated_2m} 页)")
    fi
}

release_hugepages() {
    printf "${C_CYAN}[INFO] 正在将大页内存释放回宿主机系统...${C_NC}\n"
    echo 0 > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages 2>/dev/null || true
    sysctl -w vm.nr_hugepages=0 &>/dev/null
    action_summary+=("大页内存已清空，物理内存已归还宿主机")
}

check_nvidia_busy() {
    printf "${C_CYAN}[INFO] 正在检测是否有活跃进程锁定 NVIDIA 设备...${C_NC}\n"
    
    local check_list=()
    for dev in /dev/nvidia*; do [[ -e "$dev" ]] && check_list+=("$dev"); done
    for drm in /sys/bus/pci/devices/${VGA_PCI_ID}/drm/*; do [[ -d "$drm" ]] && check_list+=("/dev/dri/$(basename "$drm")"); done

    if [[ ${#check_list[@]} -eq 0 ]]; then return 0; fi

    local pids_comma
    pids_comma=$(fuser "${check_list[@]}" 2>/dev/null | grep -oE '[0-9]+' | sort -u | tr '\n' ',' | sed 's/,$//' || true)
    
    if [[ -n "$pids_comma" ]]; then
        printf "\n${C_RED}[ERROR] 目标设备正被以下进程占用：${C_NC}\n"
        echo "--------------------------------------------------"
        ps -p "$pids_comma" -o pid,comm,args | tail -n +2 || true
        echo "--------------------------------------------------"
        
        read -rp "$(printf "${C_YELLOW}[PROMPT] 是否需要强制终止上述进程以继续？[y/N]: ${C_NC}")" kill_choice
        case "$kill_choice" in
            [Yy]* )
                printf "${C_CYAN}[INFO] 正在发送 SIGKILL 信号并尝试停止相关守护进程...${C_NC}\n"
                local pids_space=$(echo "$pids_comma" | tr ',' ' ')
                
                # 针对顽固的显卡轮询守护进程进行系统级截杀
                systemctl stop lactd 2>/dev/null || true
                systemctl stop lact 2>/dev/null || true
                
                kill -9 $pids_space 2>/dev/null || true
                sleep 1
                
                local new_pids
                new_pids=$(fuser "${check_list[@]}" 2>/dev/null | grep -oE '[0-9]+' | sort -u | tr '\n' ',' | sed 's/,$//' || true)
                
                if [[ -n "$new_pids" ]]; then
                    printf "\n${C_RED}[ERROR] 终止失败。部分进程（可能为守护进程）自动复活或拒绝响应。${C_NC}\n"
                    echo "--------------------------------------------------"
                    ps -p "$new_pids" -o pid,comm,args | tail -n +2 || true
                    echo "--------------------------------------------------"
                    printf "${C_YELLOW}[WARN] 为保护系统数据，调度已安全中止。${C_NC}\n"
                    exit 1
                else
                    printf "${C_GREEN}[OK] 进程清理完毕，目标设备句柄已释放。${C_NC}\n"
                fi
                ;;
            * )
                printf "\n${C_YELLOW}[WARN] 操作已取消。系统保持现状。${C_NC}\n"
                exit 1
                ;;
        esac
    else
        printf "${C_GREEN}[OK] 未检测到活跃的进程锁。${C_NC}\n"
    fi
}

check_vfio_running() {
    printf "${C_CYAN}[INFO] 正在检测是否有虚拟机/Hypervisor 正在锁定 VFIO 节点...${C_NC}\n"
    
    local vfio_pids
    vfio_pids=$(fuser /dev/vfio/* 2>/dev/null | grep -oE '[0-9]+' | sort -u | tr '\n' ',' | sed 's/,$//' || true)
    
    if [[ -n "$vfio_pids" ]]; then
        printf "\n${C_RED}[ERROR] VFIO 节点当前被运行中的虚拟机锁定：${C_NC}\n"
        echo "--------------------------------------------------"
        ps -p "$vfio_pids" -o pid,comm,args | tail -n +2 || true
        echo "--------------------------------------------------"
        printf "${C_YELLOW}[WARN] 在回收显卡之前，请彻底关闭虚拟机以免引发内核崩溃。${C_NC}\n\n"
        exit 1
    fi
    printf "${C_GREEN}[OK] 未检测到活跃的 VFIO 锁定。${C_NC}\n"
}

switch_mode() {
    local action_type=$1
    local target_mode=$2
    action_summary=()

    if [[ "$action_type" == "hot" ]]; then
        if [[ "$target_mode" == "vfio" ]]; then
            printf "\n${C_YELLOW}[EXEC] 正在启动动态热切换至 VFIO 直通...${C_NC}\n"
            check_nvidia_busy

            if [[ -f "/sys/bus/pci/devices/${VGA_PCI_ID}/power/control" ]]; then
                echo on > "/sys/bus/pci/devices/${VGA_PCI_ID}/power/control"
            fi

            systemctl stop nvidia-persistenced 2>/dev/null || true
            fuser -k -9 /dev/nvidia-uvm /dev/nvidia-uvm-tools /dev/nvidia* 2>/dev/null || true
            action_summary+=("清理残留进程 (SIGKILL)")

            rmmod nvidia_drm 2>/dev/null || true
            rmmod nvidia_modeset 2>/dev/null || true
            rmmod nvidia_uvm 2>/dev/null || true
            rmmod nvidia 2>/dev/null || true
            action_summary+=("卸载原生 NVIDIA 内核模块")

            allocate_hugepages

            modprobe vfio-pci
            for pci in "${NVIDIA_PCI_LIST[@]}"; do
                echo "vfio-pci" > "/sys/bus/pci/devices/${pci}/driver_override" || true
                if [[ -e "/sys/bus/pci/devices/${pci}/driver/unbind" ]]; then
                    echo "${pci}" > "/sys/bus/pci/devices/${pci}/driver/unbind" 2>/dev/null || true
                fi
                echo "${pci}" > "/sys/bus/pci/drivers_probe" || true
            done
            action_summary+=("PCI-E 设备已完成隔离并绑定至 VFIO")

            echo ""
            echo "  +------------------------------------------------"
            printf "  | ${C_BOLD}执行审计日志${C_NC}\n"
            echo "  +------------------------------------------------"
            for action in "${action_summary[@]}"; do printf "    * %s\n" "$action"; done
            echo "  +------------------------------------------------"
            printf "\n${C_GREEN}>> 动态热切换至 VFIO 完成。${C_NC}\n\n"

        elif [[ "$target_mode" == "nvidia" ]]; then
            printf "\n${C_YELLOW}[EXEC] 正在启动动态热切换至原生 NVIDIA...${C_NC}\n"
            
            check_vfio_running
            release_hugepages

            for pci in "${NVIDIA_PCI_LIST[@]}"; do
                echo "" > "/sys/bus/pci/devices/${pci}/driver_override" || true
                if [[ -e "/sys/bus/pci/devices/${pci}/driver/unbind" ]]; then
                    echo "${pci}" > "/sys/bus/pci/devices/${pci}/driver/unbind" 2>/dev/null || true
                fi
            done

            modprobe nvidia
            modprobe nvidia_drm
            modprobe nvidia_modeset
            modprobe nvidia_uvm
            for pci in "${NVIDIA_PCI_LIST[@]}"; do
                echo "${pci}" > "/sys/bus/pci/drivers_probe" || true
            done
            action_summary+=("原生 NVIDIA 驱动栈已加载，设备重新绑定成功")

            if [[ -f "/sys/bus/pci/devices/${VGA_PCI_ID}/power/control" ]]; then
                echo auto > "/sys/bus/pci/devices/${VGA_PCI_ID}/power/control"
                action_summary+=("硬件电源管理 (Runtime PM) 已恢复为 auto")
            fi

            echo ""
            echo "  +------------------------------------------------"
            printf "  | ${C_BOLD}执行审计日志${C_NC}\n"
            echo "  +------------------------------------------------"
            for action in "${action_summary[@]}"; do printf "    * %s\n" "$action"; done
            echo "  +------------------------------------------------"
            printf "\n${C_GREEN}>> 动态热切换至原生 NVIDIA 完成。${C_NC}\n\n"
        fi

    elif [[ "$action_type" == "cold" ]]; then
        if [[ ! -f "$VFIO_CONF" ]]; then
            echo "#options vfio-pci ids=YOUR_NVIDIA_GPU_ID" > "$VFIO_CONF"
        fi

        if [[ "$target_mode" == "vfio" ]]; then
            printf "\n${C_YELLOW}[EXEC] 正在应用冷启动 VFIO 隔离配置...${C_NC}\n"
            sed -i "s/^#*\(options vfio-pci ids=\).*/\1${VFIO_IDS_STR}/" "$VFIO_CONF"
            
            if [[ -f "$HUGEPAGE_CONF" ]] && grep -q "^#vm.nr_hugepages" "$HUGEPAGE_CONF"; then
                sed -i 's/^#\(vm.nr_hugepages\)/\1/' "$HUGEPAGE_CONF"
            fi
            action_summary+=("静态 IOMMU 硬件锁已更新: ${VFIO_IDS_STR}")
            
        elif [[ "$target_mode" == "nvidia" ]]; then
            printf "\n${C_YELLOW}[EXEC] 正在移除冷启动 VFIO 隔离配置...${C_NC}\n"
            sed -i 's/^\(options vfio-pci\)/#\1/' "$VFIO_CONF"
            
            if [[ -f "$HUGEPAGE_CONF" ]] && grep -q "^vm.nr_hugepages" "$HUGEPAGE_CONF"; then
                sed -i 's/^\(vm.nr_hugepages\)/#\1/' "$HUGEPAGE_CONF"
            fi
            action_summary+=("静态 IOMMU 硬件锁已清除，设备限制解除")
        fi

        printf "${C_CYAN}[INFO] 正在重新生成 initramfs 引导镜像...${C_NC}\n"
        mkinitcpio -P
        action_summary+=("initramfs 重新生成完毕 (需重启生效)")
        
        echo ""
        echo "  +------------------------------------------------"
        printf "  | ${C_BOLD}执行审计日志${C_NC}\n"
        echo "  +------------------------------------------------"
        for action in "${action_summary[@]}"; do printf "    * %s\n" "$action"; done
        echo "  +------------------------------------------------"
        printf "\n${C_GREEN}>> 冷启动配置应用成功。${C_NC}\n\n"
    fi
}

# --- Initialization ---
check_root "$@"
printf "\n"
detect_nvidia_gpu
show_status

# --- UI Menu ---
printf "  +------------------------------------------------------\n"
printf "  |  ${C_BOLD}模块 A : 动态热部署 (无需重启)${C_NC}\n"
printf "  +------------------------------------------------------\n"
printf "      ${C_GREEN}[1]${C_NC} 切换为 VFIO 直通\n"
printf "      ${C_GREEN}[2]${C_NC} 切换为原生 NVIDIA\n\n"

printf "  +------------------------------------------------------\n"
printf "  |  ${C_BOLD}模块 B : 静态烙印配置 (必须重启)${C_NC}\n"
printf "  +------------------------------------------------------\n"
printf "      ${C_GREEN}[3]${C_NC} 开机默认切换为 VFIO 直通\n"
printf "      ${C_GREEN}[4]${C_NC} 开机默认切换为原生 NVIDIA\n\n"

read -rp "$(printf "${C_BOLD}请输入执行指令 [1/2/3/4]: ${C_NC}")" choice
sleep 0.2

case "$choice" in
    1) switch_mode "hot" "vfio" ;;
    2) switch_mode "hot" "nvidia" ;;
    3) switch_mode "cold" "vfio" ;;
    4) switch_mode "cold" "nvidia" ;;
    *) printf "\n${C_RED}[ERROR] 输入无效。程序退出。${C_NC}\n"; exit 1 ;;
esac

exit 0
