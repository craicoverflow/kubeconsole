#!/bin/sh

repo_url="https://github.com/craicoverflow/kubeconsole"
release_tag=v1.0.4
plugin_file="https://raw.githubusercontent.com/craicoverflow/kubeconsole/$release_tag/plugin.yaml"
tmp_dir="/tmp"
binary_name=console

function get_tar_name {
    if has_macos; then
        echo "macos_darwin"
    elif has_linux; then
        echo "linux_amd64"
    fi
}

function get_binary_uri {
    binary_name="$(get_tar_name)"

    local binary_uri="${repo_url}/releases/download/${release_tag}/${binary_name}.tar.gz"

    echo $binary_uri
}


function has_macos {
    if [ "$(uname)" == "Darwin" ]; then
        true; return
    else
        false; return
    fi
}

function has_linux {
    if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        true; return
    else
        true; return
    fi
}

function rm_tmp_dir {
    rm -rf $tmp_dir
}

function get_oc_plugin_path {
    if [ -n "$KUBECTL_PLUGINS_PATH" ]; then
        echo $KUBECTL_PLUGINS_PATH
        return
    else
        echo "$HOME/.kube/plugins"
        return
    fi
}

function install_plugin {
    cd $tmp_dir

    binary_uri="$(get_binary_uri)"
    wget $binary_uri

    tar_name="$(get_tar_name)"
    tar_full_name="${tar_name}.tar.gz"

    tar -xvf $tar_full_name
    rm -rf $tar_full_name

    kube_plugin_dir="$(get_oc_plugin_path)"
    plugin_dir="$kube_plugin_dir/kubectl-$binary_name"

    rm -rf "$plugin_dir"

    if [ ! -d $plugin_dir ]; then
        mkdir -p "$plugin_dir"
    fi

    cp "$tar_name/$binary_name" $plugin_dir
    cd $plugin_dir
    wget $plugin_file
    
    sudo ln -sf "$PWD/$binary_name" "/usr/local/bin/kubectl-$binary_name"
    sudo ln -sf "$PWD/$binary_name" "/usr/local/bin/oc-$binary_name"
}

function init {
    install_plugin
}

init