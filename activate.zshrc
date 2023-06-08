# Add .local/bin to path (python exec gets stored here)
export PATH=/home/$USER/.local/bin:$PATH

# Add GHDL to path
export PATH=/opt/ghdl/bin:$PATH

# Set umaks to don't allow other user to write to your files
umask 022

# OH-MY-ZSH settings
export ZSH="/home/$USER/.oh-my-zsh"
ZSH_THEME="agnoster"
HIST_STAMPS="yyyy-mm-dd"
HYPHEN_INSENSITIVE="true"
plugins=(git pip)
source $ZSH/oh-my-zsh.sh

# Activator
eval "$(aactivator init)"

# Terminal Start picture, just for fun
python3 -c '
from random import randint
from os import get_terminal_size

she = """
  ██  ██   
██████████ 
  ██  ██   
██████████ 
  ██  ██   

""".splitlines()

bang = """
██  
██  
██  
    
██  
""".splitlines()
# Figure size
size = len(she[1]) + len(bang[1])

# Set colors
rnd = randint(0, 255)
color = lambda n: f"\033[38;5;{n}m"
shebangs = [(color(rnd + n % 256), color(rnd + n*n-(n+2) % 256)) for n in range(get_terminal_size().columns // size)]

# Print it
for s, b in zip(she, bang): 
  print(*("".join([n,s,m,b]) for n, m in shebangs), sep="")
print("\033[0m")
'

### ARCHIVE EXTRACTION
# usage: ex <file>
ex ()
{
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   unzstd $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
