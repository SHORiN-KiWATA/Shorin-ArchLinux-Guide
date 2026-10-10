#!/usr/bin/env python3
"""Auditable Arch installer. Plan is portable; apply requires an Arch x86_64 UEFI live ISO."""
import argparse
import hashlib
import json
import os
import platform
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent

def require(ok, message):
    if not ok:
        raise ValueError(message)

def config(path):
    c = json.loads(Path(path).read_text())
    require(isinstance(c, dict), 'Configuration must be an object')
    allowed = {'profile','disk','expected_serial','expected_model','expected_size_bytes',
               'username','hostname','cpu','gpu','nvidia_packages','swap_gib','kvm'}
    require(not set(c)-allowed, 'Unknown configuration keys: '+str(set(c)-allowed))
    require(c.get('profile') in ('video-2025','project-current'), 'Select a source profile')
    require(re.fullmatch(r'/dev/(?:sd[a-z]+|vd[a-z]+|nvme\d+n\d+)', c.get('disk','')),
            'Use the inspected whole-disk path, e.g. /dev/nvme1n1; no guessing')
    for key in ('expected_serial','expected_model'):
        require(isinstance(c.get(key),str), key+' must come from inspect')
    require(type(c.get('expected_size_bytes')) is int and c['expected_size_bytes'] >= 32*1024**3,
            'Record the exact byte size of a disk at least 32 GiB')
    require(re.fullmatch(r'[a-z_][a-z0-9_-]{0,30}',c.get('username','')) and c['username']!='root',
            'Invalid ordinary username')
    require(re.fullmatch(r'[a-zA-Z0-9][a-zA-Z0-9-]{0,62}',c.get('hostname','')), 'Invalid hostname')
    require(c.get('cpu') in ('amd','intel'), 'Detect AMD/Intel CPU')
    require(c.get('gpu') in ('amd','intel','virtual','nvidia-reviewed'), 'Detect GPU; NVIDIA needs review')
    require(type(c.get('swap_gib')) is int and 0 <= c['swap_gib'] <= 256, 'swap_gib must be 0..256')
    require(c['swap_gib']*1024**3 < c['expected_size_bytes']//2, 'Swap cannot occupy half the disk')
    require(type(c.get('kvm')) is bool, 'kvm must be a boolean')
    pkgs=c.get('nvidia_packages',[])
    require(isinstance(pkgs,list) and all(isinstance(p,str) and re.fullmatch(r'[a-z0-9][a-z0-9+._-]*',p) for p in pkgs),
            'NVIDIA packages must be a reviewed list of package names')
    if c['gpu']=='nvidia-reviewed':
        require(bool(pkgs),'Record GPU architecture and choose compatible NVIDIA package names first')
    else:
        require(not pkgs,'Only use nvidia_packages for NVIDIA')
    return c

def disk_tree():
    raw=subprocess.check_output(['lsblk','-bJpo','NAME,TYPE,SIZE,MODEL,SERIAL,MOUNTPOINTS,FSTYPE,RO'],text=True)
    return json.loads(raw)['blockdevices']

def walk(nodes):
    for n in nodes:
        yield n
        yield from walk(n.get('children',[]))

def validate_disk(c,nodes,active_swap=()):
    matches=[n for n in walk(nodes) if n['name']==c['disk']]
    require(len(matches)==1,'Configured disk was not uniquely found')
    n=matches[0]
    require(n['type']=='disk' and not n.get('ro'), 'Target must be a writable whole disk')
    require(int(n['size'])==c['expected_size_bytes'],'Disk size changed; inspect again')
    for k in ('serial','model'):
        require((n.get(k) or '').strip()==c['expected_'+k].strip(), 'Disk '+k+' mismatch')
    for child in walk([n]):
        require(not any(child.get('mountpoints') or []), 'Target disk/descendant is mounted: '+child['name'])
        require(child['name'] not in active_swap,'Target disk is active swap')
        require(child['type'] in ('disk','part'),'Target has mapped/RAID/LVM children; stop')
        holder_dir=Path('/sys/class/block')/Path(child['name']).name/'holders'
        require(not holder_dir.exists() or not list(holder_dir.iterdir()),'Target device has holders')
    return n

def validate_iso_media(c, nodes):
    # copytoram may remove the source mount; stop rather than infer its disk.
    result = subprocess.run(
        ['findmnt', '-no', 'SOURCE', '--mountpoint', '/run/archiso/bootmnt'],
        capture_output=True, text=True,
    )
    require(result.returncode == 0 and bool(result.stdout.strip()),
            'Cannot identify mounted ISO source media (e.g. copytoram); use the manual branch')
    iso_source = str(Path(result.stdout.strip().split('[')[0]).resolve())
    targets = [n for n in walk(nodes) if n['name'] == c['disk']]
    require(len(targets) == 1, 'Target disk disappeared; inspect again')
    require(not any(x['name'] == iso_source for x in walk(targets)),
            'Target is Arch ISO source media')


def q(x):
    return shlex.quote(str(x))

def render(c):
    disk=c['disk']; sep='p' if disk[-1].isdigit() else ''
    esp=disk+sep+'1'; root=disk+sep+'2'; user=c['username']
    current=c['profile']=='project-current'; ep='/efi' if current else '/boot'
    pkgs=['base','base-devel','linux','linux-headers','linux-firmware','btrfs-progs',
          'networkmanager','vim','sudo',c['cpu']+'-ucode','grub','efibootmgr','os-prober','fuse3',
          'gnome-shell','gdm','ghostty','gnome-control-center','gnome-software','flatpak',
          'nautilus','file-roller','firefox','gnome-backgrounds','xdg-user-dirs',
          'noto-fonts','noto-fonts-cjk','noto-fonts-emoji','ttf-jetbrains-mono-nerd',
          'pipewire','wireplumber','pipewire-pulse','pipewire-alsa','pipewire-jack',
          'sof-firmware','alsa-ucm-conf','bluez','power-profiles-daemon','zram-generator',
          'zsh','starship','zsh-syntax-highlighting','zsh-autosuggestions','zsh-completions',
          'ffmpegthumbnailer','gnome-keyring','gvfs-smb','gst-plugins-base','gst-plugins-good',
          'gst-libav','gnome-tweaks','gnome-text-editor','gnome-disk-utility','pacman-contrib','git']
    pkgs+=['ibus','ibus-rime'] if current else ['fcitx5','fcitx5-gtk','fcitx5-qt','fcitx5-configtool','fcitx5-chinese-addons']
    if c['gpu']=='amd':pkgs+=['mesa','vulkan-radeon']
    elif c['gpu']=='intel':pkgs+=['mesa','vulkan-intel']
    elif c['gpu']=='virtual':pkgs+=['mesa']
    else:pkgs+=c['nvidia_packages']
    if c['kvm']:pkgs+=['qemu-full','virt-manager','swtpm','dnsmasq','edk2-ovmf']
    s=['#!/usr/bin/env bash','set -euo pipefail',
       "trap 'echo \"Installation stopped. Do not rerun the format phase; inspect the last command.\" >&2' ERR",
       '# Generated plan; passwords are entered interactively and are never logged.',
       'pacman -Sy --needed --noconfirm archlinux-keyring',
       'pacman -Si '+ ' '.join(map(q,pkgs))+' >/dev/null',
       '# PACKAGE RESOLUTION ABOVE MUST PASS BEFORE ANY DISK WRITE.',
       "sfdisk --wipe always "+q(disk)+" <<'PARTITIONS'",'label: gpt',
       'size='+('1GiB' if current else '512MiB')+', type=U','type=L','PARTITIONS',
       'udevadm settle','test -b '+q(esp)+' && test -b '+q(root),
       'mkfs.fat -F 32 '+q(esp),'mkfs.btrfs -f '+q(root),
       'mount -t btrfs '+q(root)+' /mnt',
       'btrfs subvolume create /mnt/@','btrfs subvolume create /mnt/@home']
    if c['swap_gib']:s+=['btrfs subvolume create /mnt/@swap']
    s+=['umount /mnt','mount -t btrfs -o subvol=/@,compress=zstd '+q(root)+' /mnt',
        'mount --mkdir -t btrfs -o subvol=/@home,compress=zstd '+q(root)+' /mnt/home']
    if c['swap_gib']:
        s+=['mount --mkdir -t btrfs -o subvol=/@swap,compress=zstd '+q(root)+' /mnt/swap',
            'btrfs filesystem mkswapfile --size '+str(c['swap_gib'])+'g --uuid clear /mnt/swap/swapfile']
    s+=['mount --mkdir '+q(esp)+' /mnt'+ep,
        'pacstrap -K /mnt '+' '.join(map(q,pkgs)),
        'genfstab -U /mnt > /mnt/etc/fstab']
    if c['swap_gib']:s+=['printf "%s\\n" "/swap/swapfile none swap defaults 0 0" >> /mnt/etc/fstab']
    s+=['arch-chroot /mnt /bin/bash <<\'CHROOT\'','set -euo pipefail',
        'ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime','hwclock --systohc',
        "sed -i -E 's/^#(en_US.UTF-8 UTF-8|zh_CN.UTF-8 UTF-8)/\\1/' /etc/locale.gen",'locale-gen',
        "printf '%s\\n' 'LANG=en_US.UTF-8' > /etc/locale.conf",
        'printf "%s\\n" '+q(c['hostname'])+' > /etc/hostname',
        'useradd -m -G wheel '+q(user),
        "printf '%s\\n' '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel",
        'chmod 440 /etc/sudoers.d/10-wheel','visudo -c',
        'grub-install --target=x86_64-efi --efi-directory='+ep+' --bootloader-id=ARCH',
        "sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/d' /etc/default/grub",
        "printf '%s\\n' "+q('GRUB_CMDLINE_LINUX_DEFAULT="loglevel=5 nowatchdog modprobe.blacklist='+('sp5100_tco' if c['cpu']=='amd' else 'iTCO_wdt')+' zswap.enabled=0"')+' >> /etc/default/grub',
        "printf '%s\\n' '[zram0]' 'zram-size = ram' 'compression-algorithm = zstd' > /etc/systemd/zram-generator.conf",
        'systemctl enable NetworkManager gdm bluetooth power-profiles-daemon']
    if c['kvm']:s+=['systemctl enable libvirtd','usermod -aG libvirt '+q(user)]
    s+=['mkinitcpio -P','grub-mkconfig -o /boot/grub/grub.cfg','CHROOT',
        'echo "Set the root password locally (not in an AI chat):"','arch-chroot /mnt passwd',
        'echo "Set the ordinary user password locally:"','arch-chroot /mnt passwd '+q(user),
        'install -d /mnt/var/lib/shorin-install',
        'echo base-complete > /mnt/var/lib/shorin-install/stage',
        '# Skill/config copied by the Python runner after this succeeds.',
        'echo "Base+GNOME installed. After saving the skill and logs: umount -R /mnt, reboot."']
    return '\n'.join(s)+'\n'

def inspect():
    require(platform.system()=='Linux','inspect requires Linux; plan works on other systems')
    print(json.dumps({'disks':disk_tree(),'cpu':subprocess.check_output(['lscpu'],text=True),
                      'gpu':subprocess.check_output(['lspci','-nnk'],text=True)},ensure_ascii=False,indent=2))

def apply(c,config_path):
    require(platform.system()=='Linux' and platform.machine()=='x86_64','Apply requires x86_64 Linux')
    require(os.geteuid()==0,'Apply requires root in the Arch ISO')
    require(Path('/run/archiso').exists(),'Apply is only permitted inside Arch ISO Live')
    require(Path('/sys/firmware/efi/fw_platform_size').read_text().strip()=='64','Require 64-bit UEFI boot')
    require(sys.stdin.isatty(),'Apply requires a local interactive terminal for disk confirmation and passwords')
    needed=['lsblk','lscpu','lspci','sfdisk','udevadm','mkfs.fat','mkfs.btrfs','btrfs','mount','umount',
            'pacstrap','genfstab','arch-chroot','pacman','findmnt','swapon','mountpoint']
    for name in needed:require(shutil.which(name), 'Missing required command: '+name)
    require(subprocess.run(['mountpoint','-q','/mnt']).returncode!=0,'/mnt already mounted; inspect interrupted install')
    require(not any(Path('/mnt').iterdir()),'/mnt is not empty')
    marker=Path('/run/shorin-install-'+hashlib.sha256(c['disk'].encode()).hexdigest()[:16])
    require(not marker.exists(),'An apply already started on this disk. Recover manually; do not reformat')
    swap_raw=subprocess.check_output(['swapon','--show','--noheadings','--raw','--output','NAME'],text=True)
    swap_paths=swap_raw.splitlines()
    for swap_path in swap_paths:
        if not swap_path.startswith('/dev/'):
            mount_source=subprocess.check_output(['findmnt','-no','SOURCE','-T',swap_path],text=True).strip().split('[')[0]
            swap_paths.append(mount_source)
    validate_disk(c,disk_tree(),swap_paths)
    validate_iso_media(c, disk_tree())
    plan=render(c);print(plan)
    digest=hashlib.sha256(plan.encode()).hexdigest()
    token='ERASE '+c['disk']+' '+str(c['expected_size_bytes'])
    print('Plan SHA256:',digest,'\nAll partitions/data on this disk will be erased.')
    require(input('Type exactly '+token+': ').strip()==token,'Disk erase was not authorized')
    validate_disk(c,disk_tree(),swap_paths)
    marker.write_text(json.dumps({'config':c,'plan_sha256':digest}))
    fd,path=tempfile.mkstemp(prefix='shorin-install-',suffix='.sh')
    try:
        with os.fdopen(fd,'w') as f:f.write(plan)
        subprocess.run(['bash',path],check=True)
        # Persist across reboot, without provider credentials or any passwords.
        dest=Path('/mnt/root/shorin-arch-install')
        dest.mkdir(parents=True, exist_ok=True)
        for resource in ('scripts', 'assets', 'references', 'agents'):
            shutil.copytree(BASE / resource, dest / resource, dirs_exist_ok=True,
                            ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))
        for resource in ('SKILL.md', 'LICENSE.txt'):
            shutil.copy(BASE / resource, dest / resource)
        shutil.copy(config_path,dest/'install.json')
        (dest/'executed-plan.sh').write_text(plan)
        (dest/'plan-sha256.txt').write_text(digest+'\n')
        print('Next: umount -R /mnt; reboot. In the installed system, read /root/shorin-arch-install/SKILL.md.')
    finally:
        os.unlink(path)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('action',choices=['inspect','plan','apply'])
    p.add_argument('--config')
    a=p.parse_args()
    if a.action=='inspect':inspect();return
    require(a.config,'Pass --config install.json')
    c=config(a.config)
    if a.action=='plan':print(render(c),end='')
    else:apply(c,a.config)

if __name__=='__main__':
    try:main()
    except (ValueError,OSError,subprocess.CalledProcessError) as e:
        print('STOP:',e,file=sys.stderr);sys.exit(1)
