# General Purpose Gentoo Overlay

This overlay contains (mostly) self-contained ebuilds and their dependencies.
More complex dependency trees may be split off into their own overlay.

Other overlays:
* [Chia Network blockchain tools](https://github.com/ricky/chia-overlay)

## Installation

Copy [`repo.conf`](repo.conf) to `/etc/portage/repos.conf/` and update `location`
to the preferred local path.

e.g.:

```
# wget -O /etc/portage/repos.conf/ricky.conf https://raw.githubusercontent.com/ricky/gentoo-overlay/main/repo.conf
# sed -i 's/RICKY_OVERLAY_PATH/\/var\/db\/repos\/ricky/' /etc/portage/repos.conf/ricky.conf
# emerge --sync
```

Some packages may require you to
[accept `~` keywords](https://wiki.gentoo.org/wiki//etc/portage/package.accept_keywords)
for your arch, if you're primarily using stable packages.
