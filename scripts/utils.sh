# shellcheck disable=SC2148
#===============================================================================
# A little bash library to make avoiding code repetition easier :)
# Copyright (C) 2026 kvastlund.
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

#======> FIND UPWARDS <=========================================================

#-------------------------------------------------------------------------------
# Private helper function. Search using find, but go upwards.
# Arguments:
#   starting directory path
#   filename
#   directory (not path) where file is expected to be (optional)
# Outputs:
#   Hopefully the path to the file.
# Returns:
#   Hopefully 0, i guess.
#-------------------------------------------------------------------------------
private_upfind_continue() {
    local foundpath

    cd ../ || exit 1

    foundpath="$(find "$3" -name "$2" -print -quit 2>/dev/null)"

    if [[ $foundpath == "" ]]; then
        if [[ "$PWD" != "/" ]]; then
            private_upfind_continue "../$1" "$2" "$3"
        else
            exit 1
        fi
    else
        echo "$1$foundpath"
    fi
}

#-------------------------------------------------------------------------------
# Search using find, but go upwards. Starts from parent directory.
# Arguments:
#   filename
#   directory (not path) where file is expected to be (optional)
# Outputs:
#   Hopefully the path to the file.
# Returns:
#   Hopefully 0, i guess.
#-------------------------------------------------------------------------------
util_upfind() {
    private_upfind_continue "../" "$1" "$2"
}

#======> NOTIFY ABOUT TIME FOR COMMAND TO FINISH <==============================

#-------------------------------------------------------------------------------
# Measure how long it takes for the given command to finish and notify after.
# Arguments:
#   Command with arguments.
# Outputs:
#   Hopefully whatever the given command returns.
#   Notification with time.
# Returns:
#   Hopefully 0, i guess.
#-------------------------------------------------------------------------------
util_stopwatch() {
    local starttime
    local elapsedtime
    local icon
    local seconds
    local minutes
    local hours

    starttime=$(date +%s)
    "$@"
    elapsedtime=$(($(date +%s) - starttime))

    cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" || exit 1
    icon="--icon $(realpath "$(util_upfind "stopwatch.svg" "icons")")"
    cd ~- || exit 1

    seconds=$(("$elapsedtime" % 60))
    if [[ $seconds -gt 0 ]]; then
        seconds=" ${seconds}s"
    else
        seconds=" > ${seconds}s"
    fi

    minutes=$(("$elapsedtime" / 60 % 60))
    if [[ $minutes -gt 0 ]]; then
        minutes=" ${minutes}m"
    else
        minutes=""
    fi

    hours=$(("$elapsedtime" / 60 / 60 ))
    if [[ $hours -gt 0 ]]; then
        hours=" ${hours}h"
    else
        hours=""
    fi

    # shellcheck disable=SC2068
    notify-send -a "Janitor: Stopwatch" $icon "Command finished." "'$*' finished after$hours$minutes$seconds."
}

#======> CHOOSE PACKAGES AND DEPENDENCIES <=====================================

# Do this first
#-------------------------------------------------------------------------------
# Choose which packages to install, and which of those should be dependencies.
# Arguments:
#   Names of the desired packages as separate arguments.
# Outputs:
#   Chosen packages into variable 'util_packages'.
#   Chosen dependencies into variable 'util_dependencies'.
#   Whatever paru decides to output.
# Returns:
#   Hopefully 0, i guess.
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
#   None.
# Outputs:
#   Whatever paru decides to output.
# Returns:
#   Hopefully 0, i guess
#-------------------------------------------------------------------------------
util_set_deps() {
    # shellcheck disable=SC2068
    if [[ ${#util_dependencies[@]} -gt 0 ]]; then
        paru -D --asdeps ${util_dependencies[@]}
    fi
}

#======> REMOVE LEFTOVERS IN PACMAN CACHE <=====================================

#-------------------------------------------------------------------------------
# Remove supposedly temporary download directories that alpm erroneously leaves
# behind in '/var/cache/pacman/pkg/'.
# Arguments:
#   None.
# Outputs:
#   Whatever sudo and rm decides to output.
# Returns:
#   Hopefully 0, i guess.
#-------------------------------------------------------------------------------
util_remove_pacman_cache_leftovers() {
    sudo rm -df /var/cache/pacman/pkg/download-*
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

#======> DISPLAY TRUECOLOR SPECTRAL EXAMPLE <===================================

#-------------------------------------------------------------------------------
# Print a spectrum of colors.
# Mainly shamelessly stolen from <https://github.com/termstandard/colors>.
# Arguments:
#   None.
# Outputs:
#   A line of unicode characters in a simplified spectrum of colors with the
#   background in inverse colors.
# Returns:
#   Hopefully 0, i guess
#-------------------------------------------------------------------------------
util_truecolortest() {
    awk 'BEGIN{
        s="\u2584\u2584\u2584\u2584\u2584\u2584\u2584\u2584\u2584\u2584"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
}

#======> DISPLAY DATE OF BIRTH (INSTALL) <======================================

#-------------------------------------------------------------------------------
# Print the install date of the operating system, either simply or fancily.
# Arguments:
#   'fancy' : Add some flair.
# Outputs:
#   '%Y-%m-%dT%H:%M:%S%:z'
#   '\n:: Since %Y-%m-%dT%H:%M:%S%:z ::\n'
# Returns:
#   Hopefully 0, i guess
#-------------------------------------------------------------------------------
util_dateofbirth() {
    local dateofbirth
    dateofbirth=$( \
        date -Ins -d "$(stat -c %w /)" \
        | awk '{sub(/,0*/, ""); print}' \
    )

    if [[ $1 == "fancy" ]]; then
        echo -e "\n\e[35m::\e[1;4mSince $dateofbirth\e[0m \e[35m::\e[0m\n"
    else
        echo "$dateofbirth"
    fi
}

#===============================================================================
