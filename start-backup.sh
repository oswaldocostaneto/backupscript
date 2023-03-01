#!/bin/bash

# Define as cores para formatação de saída
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verifica se o número de argumentos está correto
if [ "$#" -ne 2 ]; then
    echo -e "${RED}Erro: Número inválido de argumentos. Favor informar os arquivos de lista de inclusão e exclusão.${NC}"
    exit 1
fi

# Define as variáveis de destino e listas de inclusão e exclusão
DESTINATION="/mnt/hd1t/backup"
#DESTINATION="/home/oscn/backupscript/test"
INCLUDE_LIST="$1"
EXCLUDE_LIST="$2"

# Verifica se o diretório de destino existe
if [ ! -d "$DESTINATION" ]; then
    echo -e "${RED}Erro: Diretório de destino $DESTINATION não encontrado.${NC}"
    exit 1
fi

# Lê o arquivo de lista de backup linha por linha
while read backup_folder; do
    # Define o caminho completo da pasta de origem
    source_folder="/$backup_folder"

    # Cria o comando rsync para a pasta de origem atual
    command="sudo rsync -avhr  --relative  --delete --exclude-from=$EXCLUDE_LIST --include-from=$INCLUDE_LIST $source_folder $DESTINATION"

    # Executa o comando rsync
    echo -e "${GREEN}Fazendo backup de $source_folder para $DESTINATION:${NC}"
    echo -e "${GREEN}$command${NC}"
    eval "$command" > /dev/null 2>&1
    exit_code=$?

    # Verifica o status da execução do comando rsync
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}Backup de $source_folder concluído com sucesso.${NC}"
    else
        echo -e "${RED}Erro: O backup de $source_folder falhou.${NC}"
    fi
done < "$INCLUDE_LIST"

# Salva a saída em um arquivo de log
log_file="$DESTINATION/backup.log"
echo -e "${GREEN}Registrando saída do backup em $log_file.${NC}"
echo -e "$(date +'%Y-%m-%d %H:%M:%S') - Backup concluído com sucesso." >> "$log_file"

