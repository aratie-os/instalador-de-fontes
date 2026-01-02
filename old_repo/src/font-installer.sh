#!/usr/bin/env bash

[ -f "${1}" ] || {
  echo "Você precisa fornecer um arquivo!"
  exit
}

font_file=$(readlink -f "${1}")
base_name=$(basename "${font_file}")


data=$(fc-scan --format "n:%{fullname}\ns:%{style}\nt:%{fontformat}\nf:%{family}\nd:%{foundry}\n" "${font_file}")

[ ! "${?}" == "0" ] && {
  yad --center --borders=32 --button=Ok --fixed --text="O arquivo '${font_file}' não é um arquivo de fonte válido!\n" --width=480 --title="Instalador de fontes do Tiger OS" --window-icon=font-ttf  --fixed
  exit 1 
}

font_name=$(echo "${data}"    | grep "^n:" | cut -c 3- | head -n 1)
font_style=$(echo "${data}"   | grep "^s:" | cut -c 3- | head -n 1)
font_family=$(echo "${data}"  | grep "^f:" | cut -c 3- | head -n 1)
font_type=$(echo "${data}"    | grep "^t:" | cut -c 3- | head -n 1)
font_foundry=$(echo "${data}" | grep "^d:" | cut -c 3- | head -n 1)

preview_file=$(mktemp --suffix=.png)
convert -size 736x240 -background white -font "${font_file}" -pointsize 64 -fill black -gravity center caption:"The quick brown fox jumps over the lazy dog" -flatten "${preview_file}"

yad --center --borders=32 --image-on-top --image="${preview_file}" --form --field=" ":LBL --field="Nome:":LBL --field="Estilo:":LBL --field="Tipo:":LBL --field="Família:":LBL --field="Fundação: ":LBL --field=" ":LBL --field=" ":LBL --field="${font_name}":LBL --field="${font_style}":LBL --field="${font_type}":LBL --field="${font_family}'s":LBL --field="${font_foundry}":LBL --field=" ":LBL --columns=2 --button="Cancelar":252 --button="Instalar":0 --title="Instalador de fontes do Tiger OS - ${base_name}" --window-icon=font-ttf --fixed && {
  
  mkdir -p "${HOME}/.local/share/fonts"
  cp "${font_file}" "${HOME}/.local/share/fonts"
  
  fc-cache -f -v|yad --title="Instalador de fontes do Tiger OS" --window-icon=font-ttf --center --borders=32 --no-buttons --fixed --text="Instalando a fonte ${font_name} ${font_style}\n" --progress --pulsate --auto-close --width=480 --progress-text=" " --fixed
  
  yad --center --borders=32 --button=Ok --fixed --text="A instalação foi um sucesso!\n" --width=480 --title="Instalador de fontes do Tiger OS" --window-icon=font-ttf
  
}

rm "${preview_file}"

