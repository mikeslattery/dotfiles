pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}
addpath() {
    if [ -d "$1" ]; then
        pathmunge "$@"
    fi
}
addpath "$HOME/bin"
addpath "$HOME/.local/bin"

unset -f addpath
unset -f pathmunge

