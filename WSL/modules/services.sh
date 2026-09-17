#!/usr/bin/env bash

configure_services() {
    if (( CONTAINERS )); then
        run sudo systemctl enable --now docker.service
        log 'Docker selecionado: use sudo docker; permissoes de usuario nao foram alteradas.'
    fi
    if (( POSTGRES )); then
        log 'PostgreSQL selecionado: pacote apenas; nenhum banco sera inicializado ou iniciado.'
    fi
    if (( GPU )); then
        log 'Toolkit NVIDIA selecionado: confira o driver Windows e configure o runtime quando precisar.'
    fi
}
