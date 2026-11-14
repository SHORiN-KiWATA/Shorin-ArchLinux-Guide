import copy
import importlib.util
import json
import tempfile
import subprocess
import unittest
from pathlib import Path
from unittest.mock import patch

SKILL=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('installer',SKILL/'scripts/install.py')
i=importlib.util.module_from_spec(spec);spec.loader.exec_module(i)

class InstallerTest(unittest.TestCase):
    def setUp(self):
        self.c={'profile':'video-2025','disk':'/dev/nvme1n1','expected_serial':'UNITTEST-SERIAL',
                'expected_model':'UNITTEST-DISK','expected_size_bytes':128*1024**3,
                'username':'archuser','hostname':'archlinux','cpu':'amd','gpu':'amd',
                'nvidia_packages':[],'swap_gib':4,'kvm':False}
        self.nodes=[{'name':self.c['disk'],'type':'disk','size':self.c['expected_size_bytes'],
                     'serial':'UNITTEST-SERIAL','model':'UNITTEST-DISK','ro':False,
                     'mountpoints':[None],'children':[{'name':'/dev/nvme1n1p1','type':'part','size':1024,'mountpoints':[None]}]}]
    def load(self,c):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'c.json';p.write_text(json.dumps(c));return i.config(p)
    def test_example_cannot_install(self):
        with self.assertRaises(ValueError):i.config(SKILL/'assets/install.example.json')
    def test_valid_config(self):self.assertEqual(self.load(self.c),self.c)
    def test_shell_injection_rejected(self):
        for k,v in [('username','x; touch /tmp/bad'),('disk','/dev/sda;reboot'),('hostname','$(id)')]:
            c=copy.deepcopy(self.c);c[k]=v
            with self.subTest(k=k),self.assertRaises(ValueError):self.load(c)
    def test_unknown_keys_rejected(self):
        self.c['password']='test'
        with self.assertRaises(ValueError):self.load(self.c)
    def test_video_profile_is_boot(self):
        s=i.render(self.c);self.assertIn('/mnt/boot',s);self.assertIn('--efi-directory=/boot',s)
        self.assertIn('mkfs.btrfs -f /dev/nvme1n1p2',s)
        self.assertLess(s.index('pacman -Si'),s.index('sfdisk --wipe'))
        self.assertIn('arch-chroot /mnt passwd archuser',s)
    def test_current_profile_is_efi(self):
        self.c['profile']='project-current';s=i.render(self.c)
        self.assertIn('/mnt/efi',s);self.assertIn('--efi-directory=/efi',s);self.assertIn('ibus-rime',s)
    def test_sata_partition_names(self):
        self.c['disk']='/dev/sdb';s=i.render(self.c);self.assertIn('mkfs.btrfs -f /dev/sdb2',s)
        self.assertNotIn('/dev/sdbp2',s)
    def test_no_swap_has_no_swap_mount(self):
        self.c['swap_gib']=0;s=i.render(self.c);self.assertNotIn('mkswapfile',s);self.assertNotIn('/mnt/@swap',s)
    def test_cpu_microcode(self):
        self.c['cpu']='intel';s=i.render(self.c);self.assertIn('intel-ucode',s);self.assertIn('iTCO_wdt',s);self.assertNotIn('amd-ucode',s)
    def test_nvidia_requires_explicit_packages(self):
        self.c['gpu']='nvidia-reviewed'
        with self.assertRaises(ValueError):self.load(self.c)
        self.c['nvidia_packages']=['nvidia-open-dkms','nvidia-utils'];self.load(self.c)
    def test_disk_identity(self):
        self.assertEqual(i.validate_disk(self.c,self.nodes)['name'],self.c['disk'])
        for key,v in [('serial','wrong'),('model','wrong'),('size',10),('ro',True)]:
            ns=copy.deepcopy(self.nodes);ns[0][key]=v
            with self.subTest(key=key),self.assertRaises(ValueError):i.validate_disk(self.c,ns)
    def test_descendant_mount_blocks_erase(self):
        self.nodes[0]['children'][0]['mountpoints']=['/run/archiso/bootmnt']
        with self.assertRaises(ValueError):i.validate_disk(self.c,self.nodes)
    def test_active_swap_blocks_erase(self):
        with self.assertRaises(ValueError):i.validate_disk(self.c,self.nodes,['/dev/nvme1n1p1'])
    def test_mapped_device_blocks_erase(self):
        self.nodes[0]['children'][0]['type']='crypt'
        with self.assertRaises(ValueError):i.validate_disk(self.c,self.nodes)
    def test_unknown_iso_source_blocks_erase(self):
        result=subprocess.CompletedProcess([],1,stdout='',stderr='')
        with patch.object(i.subprocess,'run',return_value=result),self.assertRaises(ValueError):
            i.validate_iso_media(self.c,self.nodes)
    def test_iso_backing_partition_blocks_erase(self):
        result=subprocess.CompletedProcess([],0,stdout='/dev/nvme1n1p1\n',stderr='')
        with patch.object(i.subprocess,'run',return_value=result),self.assertRaises(ValueError):
            i.validate_iso_media(self.c,self.nodes)
    def test_other_disk_iso_is_allowed(self):
        result=subprocess.CompletedProcess([],0,stdout='/dev/sdz1\n',stderr='')
        with patch.object(i.subprocess,'run',return_value=result):i.validate_iso_media(self.c,self.nodes)
    def test_generated_plans_are_valid_shell(self):
        for profile in ('video-2025','project-current'):
            for disk in ('/dev/sda','/dev/vda','/dev/nvme1n1'):
                for swap in (0,4):
                    c=copy.deepcopy(self.c);c.update(profile=profile,disk=disk,swap_gib=swap,kvm=True)
                    result=subprocess.run(['bash','-n'],input=i.render(c),text=True,capture_output=True)
                    self.assertEqual(result.returncode,0,result.stderr)
    def test_other_os_cannot_apply(self):
        with patch.object(i.platform,'system',return_value='Darwin'),self.assertRaises(ValueError):i.apply(self.c,'irrelevant.json')

if __name__=='__main__':unittest.main()
