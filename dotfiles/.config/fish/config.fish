if status is-interactive
    # Commands to run in interactive sessions can go here
end
set fish_greeting ""
set -p PATH ~/.local/bin
starship init fish | source
zoxide init fish --cmd cd | source

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

function ls
	command eza --icons $argv
end

# 小黄鸭补帧 需要steam安装正版小黄鸭
abbr lsfg 'LSFG_PROCESS="miyu"'
# fa运行fastfetch
abbr fa fastfetch
abbr reboot 'systemctl reboot'
function 滚
	sysup 
end
function 更新
	sysup 
end
function 清理
	command clean $argv
end

function 安装
	command pac $argv
end
function 卸载
	command par $argv
end
function install
	command pac $argv
end
function remove 
	command pacr $argv
end
function raw
	command ~/.config/scripts/random-anime-wallpaper.sh $argv
end

