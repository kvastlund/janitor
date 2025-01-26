# Scripts
A collection of personal scripts.

## Requirements
Arch Linux base: [archlinux.org/packages/core/any/base](https://archlinux.org/packages/core/any/base/)\
pacman-contrib (for `clean`, `in`, `out`, `up`): [archlinux.org/packages/extra/x86_64/pacman-contrib](https://archlinux.org/packages/extra/x86_64/pacman-contrib/)\
misfortune (for `hi`): [archlinux.org/packages/extra/x86_64/misfortune](https://archlinux.org/packages/extra/x86_64/misfortune/)\
cowsay (for `hi`): [archlinux.org/packages/extra/any/cowsay](https://archlinux.org/packages/extra/any/cowsay/)\
fastfetch (for `hi`): [archlinux.org/packages/extra/x86_64/fastfetch](https://archlinux.org/packages/extra/x86_64/fastfetch/)\
mpv (for `mpvwebcam`): [archlinux.org/packages/extra/x86_64/mpv](https://archlinux.org/packages/extra/x86_64/mpv/)\
kde-cli-tools (for `rm`): [archlinux.org/packages/extra/x86_64/kde-cli-tools](https://archlinux.org/packages/extra/x86_64/kde-cli-tools/)\
paru-git or other paru (for `clean`, `hi`, `in`, `out`, `up`): [aur.archlinux.org/packages/paru-git](https://aur.archlinux.org/packages/paru-git/)

## Setup
Run `/path/to/memma --install`. This requires root privilege. This will create a symlink to `memma` in `/usr/local/bin`, which is assumed to be on your `$PATH`. Run `memma --uninstall` to remove the symlink.

## Usage
`memma -h` - Print help message containing available operations.

## License
[GPL3](LICENSE) © [kvastlund](https://github.com/kvastlund).
