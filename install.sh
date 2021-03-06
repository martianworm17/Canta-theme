#!/bin/bash
#set -ueo pipefail
#set -x

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SRC_DIR=`dirname "$0"`
THEME_NAME=Canta
COLOR_VARIANTS=('' '-dark' '-light')
SIZE_VARIANTS=('' '-compact')

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-c, --color VARIANTS..." "Specify theme color variant(s) [standard|dark|light] (Default: All variants)"
  printf "  %-25s%s\n" "-s, --size VARIANT" "Specify theme size variant [standard|compact] (Default: All variants)"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
  printf "\n%s\n" "INSTALLATION EXAMPLES:"
  printf "%s\n" "Install all theme variants into ~/.themes"
  printf "  %s\n" "$0 --dest ~/.themes"
  printf "%s\n" "Install standard theme variant only"
  printf "  %s\n" "$0 --color standard --size standard"
  printf "%s\n" "Install specific theme variants with different name into ~/.themes"
  printf "  %s\n" "$0 --dest ~/.themes --name MyTheme --color light dark --size compact"
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local size=${4}

  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}
  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}

  local THEME_DIR=${dest}/${name}${color}${size}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                           ${THEME_DIR}
  cp -ur ${SRC_DIR}/COPYING                                                          ${THEME_DIR}
  cp -ur ${SRC_DIR}/AUTHORS                                                          ${THEME_DIR}

  echo "[Desktop Entry]" >> ${THEME_DIR}/index.theme
  echo "Type=X-GNOME-Metatheme" >> ${THEME_DIR}/index.theme
  echo "Name=Canta${color}${size}" >> ${THEME_DIR}/index.theme
  echo "Comment=An Flat Gtk+ theme based on Material Design" >> ${THEME_DIR}/index.theme
  echo "Encoding=UTF-8" >> ${THEME_DIR}/index.theme
  echo "" >> ${THEME_DIR}/index.theme
  echo "[X-GNOME-Metatheme]" >> ${THEME_DIR}/index.theme
  echo "GtkTheme=Canta${color}${size}" >> ${THEME_DIR}/index.theme
  echo "MetacityTheme=Canta${color}${size}" >> ${THEME_DIR}/index.theme
  echo "IconTheme=Adwaita" >> ${THEME_DIR}/index.theme
  echo "CursorTheme=Adwaita" >> ${THEME_DIR}/index.theme
  echo "ButtonLayout=menu:minimize,maximize,close" >> ${THEME_DIR}/index.theme

  mkdir -p                                                                           ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/{*.svg,extensions,noise-texture.png,pad-osd.css} ${THEME_DIR}/gnome-shell
  cp -ur ${SRC_DIR}/src/gnome-shell/assets${ELSE_DARK}                               ${THEME_DIR}/gnome-shell/assets
  cp -ur ${SRC_DIR}/src/gnome-shell/gnome-shell${color}${size}.css     ${THEME_DIR}/gnome-shell/gnome-shell.css
  glib-compile-resources \
    --sourcedir=${THEME_DIR}/gnome-shell \
    --target=${THEME_DIR}/gnome-shell/gnome-shell-theme.gresource \
    ${SRC_DIR}/src/gnome-shell/gnome-shell-theme.gresource.xml

  mkdir -p                                                                           ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/{apps.rc,hacks.rc,main.rc}                           ${THEME_DIR}/gtk-2.0
  cp -ur ${SRC_DIR}/src/gtk-2.0/assets${ELSE_DARK}                                   ${THEME_DIR}/gtk-2.0/assets
  cp -ur ${SRC_DIR}/src/gtk-2.0/gtkrc${color}                                        ${THEME_DIR}/gtk-2.0/gtkrc

  cp -ur ${SRC_DIR}/src/gtk/assets                                                   ${THEME_DIR}/gtk-assets

  mkdir -p                                                                           ${THEME_DIR}/gtk-3.0
  ln -sf ../gtk-assets                                                               ${THEME_DIR}/gtk-3.0/assets
  cp -ur ${SRC_DIR}/src/gtk/gtk${color}${size}.css                                   ${THEME_DIR}/gtk-3.0/gtk.css
  [[ ${color} != '-dark' ]] && \
  cp -ur ${SRC_DIR}/src/gtk/gtk-dark${size}.css                                      ${THEME_DIR}/gtk-3.0/gtk-dark.css


  mkdir -p                                                                           ${THEME_DIR}/metacity-1
  cp -ur ${SRC_DIR}/src/metacity-1/assets                                            ${THEME_DIR}/metacity-1
  cp -ur ${SRC_DIR}/src/metacity-1/metacity-theme-2${ELSE_LIGHT}.xml                 ${THEME_DIR}/metacity-1/metacity-theme-2.xml
  cp -ur ${SRC_DIR}/src/metacity-1/metacity-theme-3${ELSE_LIGHT}.xml                 ${THEME_DIR}/metacity-1/metacity-theme-3.xml

  mkdir -p                                                                           ${THEME_DIR}/unity
  cp -ur ${SRC_DIR}/src/unity/{*.svg,*.png,dash-widgets.json}                        ${THEME_DIR}/unity
  cp -ur ${SRC_DIR}/src/unity/assets${ELSE_LIGHT}                                    ${THEME_DIR}/unity/assets

  mkdir -p                                                                           ${THEME_DIR}/xfwm4
  cp -ur ${SRC_DIR}/src/xfwm4/{*.svg,themerc}                                        ${THEME_DIR}/xfwm4
  cp -ur ${SRC_DIR}/src/xfwm4/assets${ELSE_LIGHT}                                    ${THEME_DIR}/xfwm4/assets
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -c|--color)
      shift
      for variant in "${@}"; do
        case "${variant}" in
          standard)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[2]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--size)
      shift
      for variant in "${@}"; do
        case "${variant}" in
          standard)
            sizes+=("${SIZE_VARIANTS[0]}")
            shift
            ;;
          compact)
            sizes+=("${SIZE_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized size variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ ! -w "${dest:-${DEST_DIR}}" ]]; then
  echo "Please run as root."
  exit 1
fi

for color in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
  for size in "${sizes[@]:-${SIZE_VARIANTS[@]}}"; do
    install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${size}"
  done
done

echo
echo Done.
