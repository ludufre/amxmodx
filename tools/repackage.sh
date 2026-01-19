#!/bin/bash

# Script para reempacotar zips do AMX Mod X
# Formato de saída: amxmodx-<version>-git<gitversion>-xash-<subfolder>-<platform>.zip

set -e

WORKDIR=$(pwd)
TEMPDIR="$WORKDIR/temp_extract"
OUTDIR="$WORKDIR/output"

# Criar diretórios
mkdir -p "$OUTDIR"

# Mapear plataformas dos nomes dos arquivos
get_platform() {
    local filename="$1"
    if [[ "$filename" == *"-windows-msvc-"* ]]; then
        echo "windows"
    elif [[ "$filename" == *"-linux-gcc-9-"* ]]; then
        echo "linux-gcc9"
    elif [[ "$filename" == *"-linux-clang-11-"* ]]; then
        echo "linux-clang11"
    else
        echo "unknown"
    fi
}

# Extrair versão e git version do nome do arquivo
# Formato: amxmodx-1.9.0-git5302-xash-linux-gcc-9-<hash>.zip
get_version() {
    local filename="$1"
    echo "$filename" | sed -E 's/amxmodx-([0-9.]+)-git.*/\1/'
}

get_gitversion() {
    local filename="$1"
    echo "$filename" | sed -E 's/amxmodx-[0-9.]+-git([0-9]+)-.*/\1/'
}

# Processar cada zip
for zipfile in "$WORKDIR"/amxmodx-*.zip; do
    [ -f "$zipfile" ] || continue

    filename=$(basename "$zipfile")
    echo "Processando: $filename"

    version=$(get_version "$filename")
    gitversion=$(get_gitversion "$filename")
    platform=$(get_platform "$filename")

    echo "  Versão: $version, Git: $gitversion, Plataforma: $platform"

    # Criar diretório temporário
    rm -rf "$TEMPDIR"
    mkdir -p "$TEMPDIR"

    # Extrair zip
    unzip -q "$zipfile" -d "$TEMPDIR"

    # Para cada subpasta (base, cstrike, etc.)
    for subfolder in "$TEMPDIR"/*/; do
        [ -d "$subfolder" ] || continue

        subname=$(basename "$subfolder")
        outname="amxmodx-${version}-git${gitversion}-xash-${subname}-${platform}.zip"

        echo "  Criando: $outname"

        # Entrar na pasta temporária e criar zip com o conteúdo da subpasta
        cd "$TEMPDIR"
        zip -rq "$OUTDIR/$outname" "$subname"
        cd "$WORKDIR"
    done

    # Limpar
    rm -rf "$TEMPDIR"
done

echo ""
echo "Concluído! Arquivos gerados em: $OUTDIR"
ls -la "$OUTDIR"
