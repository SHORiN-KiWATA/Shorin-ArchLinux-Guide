建立并推送：

```bash
git clone ssh://aur@aur.archlinux.org/shorin-dms-niri-meta.git
cd shorin-dms-niri-meta
```

```bash
makepkg --printsrcinfo > .SRCINFO
```

```bash
git add PKGBUILD .SRCINFO
git commit -m "Initial commit: Add meta package"
git push
```
