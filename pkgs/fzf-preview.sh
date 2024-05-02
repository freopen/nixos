if [[ $# -ne 1 ]]; then
  >&2 echo "usage: $0 FILENAME"
  exit 1
fi

file=${1/#\~\//$HOME/}
type=$(file --dereference --mime -- "$file")

if [[ ! $type =~ image/ ]]; then
  if [[ $type =~ =binary ]]; then
    file "$1"
    exit
  fi

  bat --style="${BAT_STYLE:-numbers}" --color=always --pager=never -- "$file"
  exit
fi

dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}

chafa -f sixel -s "$dim" --scale max "$file"
# Add a new line character so that fzf can display multiple images in the preview window
echo
