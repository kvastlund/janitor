# shellcheck disable=SC2148
#===============================================================================
# A little bash library to make avoiding code repetition easier :)
# Copyright (C) 2026 kvastlund
#
# This file is part of Janitor.
#
# Janitor is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# Janitor is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Janitor. If not, see <https://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------
# Source this file: `$source /path/to/utils.sh` or `$. /path/to/utils.sh`
#======> CHOOSE PACKAGES AND DEPENDENCIES <=====================================

# Do this first
#-------------------------------------------------------------------------------
# Choose which packages to install, and which of those should be dependencies.
# Arguments:
#   Names of the desired packages as separate arguments.
# Outputs:
#   Chosen packages into variable 'util_packages'
#   Chosen dependencies into variable 'util_dependencies'
#   Whatever paru decides to output
# Returns:
#   Hopefully 0, i guess
#-------------------------------------------------------------------------------
declare -a util_packages util_dependencies

util_setup_pkgs() {
    # Choose packages
    for query in "${@:1}"; do
        local pkgsraw
        pkgsraw=$(paru -Ss --interactive --bottomup --color always "$query" \
            | tee /dev/stderr \
            | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")

        local pkgsstring
        pkgsstring=$(echo "${pkgsraw##*:}" | xargs)

        if [[ ($pkgsstring != "") \
            && ($pkgsstring != "there is nothing to do") ]]; then
            util_packages+=("$pkgsstring")
        fi
    done

    echo # Add some breathing room

    # Choose dependencies
    # shellcheck disable=SC2068
    for pkg in ${util_packages[@]}; do
        while true; do
            echo -ne "\e[1m"
            read -p "Install $pkg as a dependency? [y/N] " -n 1 -r
            echo -ne "\e[0m"

            [[ $REPLY == "" ]] && break
            echo
            [[ ($REPLY =~ ^[Yy]$) || ($REPLY =~ ^[Nn]$) ]] && break
        done

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            util_dependencies+=("$(echo "$pkg" | cut -d '/' -f 2)")
        fi
    done
}

# Install your packages in between

# Then do this
#-------------------------------------------------------------------------------
# Set specified packages as dependencies.
# Arguments:
#   None
# Outputs:
#   Whatever paru decides to output
# Returns:
#   Hopefully 0, i guess
#-------------------------------------------------------------------------------
util_set_deps() {
    # shellcheck disable=SC2068
    if [[ ${#util_dependencies[@]} -gt 0 ]]; then
        paru -D --asdeps ${util_dependencies[@]}
    fi
}

#======> DISPLAY MIRRORLIST RETIREVED TIME <====================================

#-------------------------------------------------------------------------------
# Write the time when reflector retrieved the current mirrorlist to stdout.
# Arguments:
#   'pad'   : Insert an empty line before and after the message, if it exists.
# Outputs:
#   Nothing.
#   'The current mirrorlist was retrieved at %Y-%m-%d %H:%M:%S UTC.\n'
#   '\nThe current mirrorlist was retrieved at %Y-%m-%d %H:%M:%S UTC.\n\n'
# Returns:
#   Hopefully 0, i guess
#-------------------------------------------------------------------------------
util_mirtime() {
    local retrieved_time
    retrieved_time=$(pacman -v 2> /dev/null \
        | grep 'Conf File' \
        | cut -d ' ' -f 4 \
        | xargs cat \
        | grep '\[core\]' -A 1 \
        | grep 'Include' \
        | cut -d ' ' -f 3 \
        | xargs cat \
        | grep 'Retrieved' \
        | cut -d ' ' -f 4,5,6)

    if [[ $retrieved_time != "" ]]; then
        [[ $1 == "pad" ]] && echo
        echo "The current mirrorlist was retrieved at $retrieved_time."
        [[ $1 == "pad" ]] && echo
    fi
}

#===============================================================================
