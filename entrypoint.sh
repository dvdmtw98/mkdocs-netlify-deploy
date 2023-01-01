#!/bin/bash

set -e

print_info () {
    echo -e "\033[0;93m $1 \033[0m"
}

social_plugin_dependencies () {
    if [[ "${INPUT_SOCIAL_PLUGIN_USED}" == "true" ]];
    then
        print_info "Installing extra packages required by mkdocs social plugin..."
        apt-get install -y libcairo2-dev libfreetype6-dev libffi-dev libjpeg-dev libpng-dev libz-dev
    fi
}

manual_setup_configuration () {
    print_info "Starting manual configuration mode..."
    mkdir -p mkdocs/{docs,hooks}

    if [[ -z "${INPUT_MAIN_REPO_ACCESS_TOKEN}" ]]; 
    then
        github_main_repo_url="https://github.com/${INPUT_MAIN_REPOSITORY}.git"
    else
        github_main_repo_url="https://${INPUT_MAIN_REPO_ACCESS_TOKEN}@github.com/${INPUT_MAIN_REPOSITORY}.git"
    fi

    main_directory_name=$(echo "${INPUT_MAIN_REPOSITORY}" | cut -d "/" -f 2)

    print_info "Cloning the Repo 1 with Markdown files..."
    git clone $github_main_repo_url

    if [[ ! "${INPUT_MAIN_REPO_CHECKOUT}" == "main" ]]; 
    then
        cd ${main_directory_name}
        print_info "Switching branch to specified one..."
        git checkout ${INPUT_MAIN_REPO_CHECKOUT}
        cd ..
    fi

    print_info "Copying over Markdown files into mkdocs folder..."
    cp -r "${main_directory_name}/${INPUT_MARKDOWN_LOCATION}/"* mkdocs/docs

    # Config Repo related Logic

    if [[ -z "${INPUT_CONFIG_REPO_ACCESS_TOKEN}" ]]; 
    then
        github_config_repo_url="https://github.com/${INPUT_CONFIG_REPOSITORY}.git"
    else
        github_config_repo_url="https://${INPUT_CONFIG_REPO_ACCESS_TOKEN}@github.com/${INPUT_CONFIG_REPOSITORY}.git"
    fi

    config_directory_name=$(echo "${INPUT_CONFIG_REPOSITORY}" | cut -d "/" -f 2)

    print_info "Cloning Repo 2 with Mkdocs config files..."
    git clone ${github_config_repo_url}

    if [[ ! "${INPUT_CONFIG_REPO_CHECKOUT}" == "main" ]]; 
    then
        cd ${config_directory_name}
        print_info "Switching branch to specified one..."
        git checkout ${INPUT_CONFIG_REPO_CHECKOUT}
        cd ..
    fi

    if [[ "${INPUT_ASSETS_AND_HOOKS_PRESENT}" == "true" ]]; 
    then
        print_info "Copying over assets and hooks folder..."

        if [ -d "${config_directory_name}/${INPUT_ASSETS_LOCATION}" ]; 
        then
            mkdir -p mkdocs/docs/assets
            cp -r "${config_directory_name}/${INPUT_ASSETS_LOCATION}/"* mkdocs/docs/assets
        fi

        if [ -d "${config_directory_name}/${INPUT_HOOKS_LOCATION}" ]; 
        then
            cp -r "${config_directory_name}/${INPUT_HOOKS_LOCATION}/"* mkdocs/hooks
        fi
    fi

    if [[ ${INPUT_CONFIG_LOCATION} == "/" ]];
    then
        config_directory="${config_directory_name}"
    else
        config_directory="${config_directory_name}/${INPUT_CONFIG_LOCATION}"
    fi

    if [[ -f "${config_directory}/mkdocs.yml" && -f "${config_directory}/requirements.txt" ]]; 
    then
        print_info "Copying requirements.txt and mkdocs.yml file..."
        cp "${config_directory}/mkdocs.yml" "${config_directory}/requirements.txt" mkdocs/
    else
        print_info "mkdocs.yml and/or requirements.txt file not found..."
        exit 1
    fi
}

partial_setup_configuration () {
    print_info "Implementation Pending..."
    exit 1
}

auto_setup_configuration () {
    print_info "Starting auto configuration mode..."
    mkdir mkdocs

    if [[ -z "${INPUT_MAIN_REPO_ACCESS_TOKEN}" ]]; 
    then
        github_main_repo_url="https://github.com/${INPUT_MAIN_REPOSITORY}.git"
    else
        github_main_repo_url="https://${INPUT_MAIN_REPO_ACCESS_TOKEN}@github.com/${INPUT_MAIN_REPOSITORY}.git"
    fi

    main_directory_name=$(echo "${INPUT_MAIN_REPOSITORY}" | cut -d "/" -f 2)

    print_info "Cloning Repo..."
    git clone $github_main_repo_url

    if [[ ! "${INPUT_MAIN_REPO_CHECKOUT}" == "main" ]]; 
    then
        cd ${main_directory_name}
        print_info "Switching branch to specified one..."
        git checkout ${INPUT_MAIN_REPO_CHECKOUT}
        cd ..
    fi

    print_info "Copying over files into mkdocs folder..."
    cp -r "${main_directory_name}/"* mkdocs
}

build_mkdocs_site () {
    cd mkdocs
    
    print_info "Configuring pip and installing the requirements..."
    pip install -r requirements.txt --no-cache-dir --no-warn-script-location

    print_info "Starting Mkdocs build (This can take a while)..."
    mkdocs build
}

deploy_to_netlify () {
    print_info "Starting deployment to Netlify (This can also take a while)..."
    time=$(date)

    netlify_output=$(
        netlify deploy --json --auth $INPUT_NETLIFY_AUTH_TOKEN --dir site \
        --message "GitHub Actions deployment : ${time}" --site $INPUT_NETLIFY_SITE_ID --prod
    )
}

main () {
    cd /tmp

    social_plugin_dependencies

    if [[ "${INPUT_BUILD_MODE}" == "manual" ]]; 
    then 
        manual_setup_configuration
    elif [[ "${INPUT_BUILD_MODE}" == "partial" ]];
    then
        partial_setup_configuration
    elif [[ "${INPUT_BUILD_MODE}" == "auto" ]]; 
    then
        auto_setup_configuration
    else
        print_info "Invalid value provided for Build Mode. Exiting..."
        exit 1
    fi

    build_mkdocs_site

    deploy_to_netlify
}

main