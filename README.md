# Janitor
A collection of utility scripts.

## Requirements
Arch Linux base: [archlinux.org/packages/core/any/base](https://archlinux.org/packages/core/any/base/)\
pacman-contrib (for `clean`, `installpkg`, `removepkg`, `upgrade`): [archlinux.org/packages/extra/x86_64/pacman-contrib](https://archlinux.org/packages/extra/x86_64/pacman-contrib/)\
mpv (for `mpvwebcam`): [archlinux.org/packages/extra/x86_64/mpv](https://archlinux.org/packages/extra/x86_64/mpv/)\
kde-cli-tools (for `expel`): [archlinux.org/packages/extra/x86_64/kde-cli-tools](https://archlinux.org/packages/extra/x86_64/kde-cli-tools/)\
paru (for `clean`, `installpkg`, `removepkg`, `upgrade`, `sysinfo`): [aur.archlinux.org/packages/paru-git](https://aur.archlinux.org/packages/paru-git/)

### Optional requirements
<details>
<summary>fastfetch or equivalent (for <code>sysinfo</code>): <a href="https://archlinux.org/packages/extra/x86_64/fastfetch/">archlinux.org/packages/extra/x86_64/fastfetch</a> </summary>

    fastfetch
    hyfetch
    macchina
    screenfetch
    archey
    neofetch
    ufetch
    pfetch
    alsi
    catnap
    zeptofetch
    onefetch
    uwufetch
    footfetch
    nitch
    nitchrevived
    zeitfetch
    nanofetch
    wretch
    albafetch
    aerofetch
    ffetch
    paleofetch
    rxfetch
    nerdfetch
    brokefetch

</details>

misfortune (for `greet`): [archlinux.org/packages/extra/x86_64/misfortune](https://archlinux.org/packages/extra/x86_64/misfortune/)\
cowsay (for `greet`): [archlinux.org/packages/extra/any/cowsay](https://archlinux.org/packages/extra/any/cowsay/)

## Setup
Install:
```bash
/path/to/janitor --install
```
This requires `sudo` access. This will create a symlink to `janitor` in `/usr/local/bin`, which is assumed to be on your `$PATH`.

Uninstall:
```bash
janitor --uninstall
```
This requires `sudo` access. This will remove the symlink that was created during installation.

## Usage
Display help message containing available operations:
```bash
janitor -h
```

## License
[GPL3](LICENSE) © [kvastlund](https://github.com/kvastlund).
