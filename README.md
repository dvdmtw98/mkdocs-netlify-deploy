# Mkdocs Site Build and Netlify Deploy Action

This GitHub Action allows you to build a Mkdocs site and then deploy the resulting website to Netlify. 

There are three different build options that are supported (auto, partial, manual). This action comes pre-configured with the dependencies required to use the social plugin provided my Mkdocs Material and can be easily enabled by changing the default options. Hook files (scripts executed before the Mkdocs build process) can also be used by the Action.

### Build using Auto Mode
In the mode the files that are present in a single repository is copied as is into the destination directory where the final site will be compiled. This mode provides the least flexibility with the idea if the repository contains all the files in the structure used by Mkdocs.

### Build using Partial Mode (Not yet Implemented)
In this mode the source files are all present in a single repository but they are not stored in the structure that is used by Mkdocs. The user can specify the folder that contains the Markdown files as well as the folder that stored static assets, hook files (Scripts that can be executed before the build process) and the configuration files (mkdocs.yml, requirements.txt) to setup Mkdocs.

### Build using Manual Mode
In this mode the Markdown files are stored in one repository while all the configuration and auxiliary files required by Mkdocs are stored in a different repository. Similar to Partial Mode the user can still specific the directories that stored the Markdown and configuration files. This mode offers the most flexibility and was add specify to met my personal obscure usage pattern.

## Input Parameters

| **Parameter Name**         | **Type** | **Default** | **Description**                                                |
|----------------------------|:--------:|:-----------:|----------------------------------------------------------------|
| `build_mode`               | required |     auto    | Build approach to use for building site                        |
| `main_repository`          | required |             | Repository 1 Name                                              |
| `main_repo_checkout`       | optional |     main    | Branch, Hash of repository to use                              |
| `main_repo_access_token`   | required |             | Token required to access repository                            |
| `config_repository`        | optional |             | Repository 2 Name (Only required in manual mode)               |
| `config_repo_checkout`     | optional |     main    | Branch, Hash from repository to use                            |
| `config_repo_access_token` | optional |             | Token required to access repository                            |
| `markdown_location`        | optional |     docs    | Directory containing Markdown files                            |
| `assets_and_hooks_present` | optional |     true    | Denote Assets/ Hooks are required                              |
| `assets_location`          | optional |    assets   | Directory containing Mkdocs Assets                             |
| `hooks_location`           | optional |    hooks    | Directory containing Hook files                                |
| `config_location`          | optional |      .      | Location of mkdocs.yml and requirements.txt file               |
| `netlify_auth_token`       | required |             | PAT Token to authenticate with Netlify                         |
| `netlify_site_id`          | required |             | Target Netlify Site ID                                         |
| `social_plugin_used`       | optional |    false    | Install dependencies required by Material Mkdocs social plugin |

**Additional Details**
- `main_repository` & `config_repository` need to specific as username/repo-name (e.g. dvdmtw99/mkdocs-site-builder)
- `main_repo_access_token` and `config_repo_access_token` need to be a Personal Access Token (PAT)
- Personal Access Token is not required if the repositories are public
- If `social_plugin_used` is set to false and mkdocs config contains the social plugin the build process will fail
- When using auto build mode all the location related inputs will be ignored if used
- When using the location related inputs do not include ./ and trailing / at the end
- If the markdown files are present at the root of the repository (when using manual mode) use /
- If the path contains any special characters they do not need to be escaped or enclosed in ""

## Example Usage

```yaml
name: 'Mkdocs Build & Deploy Workflow'
on:
  push:
    branches: [ main ]

jobs:
  testing:
    runs-on: ubuntu-latest
    steps:
      - name: 'Mkdocs Build & Deploy'
        id: mkdocs-build
        uses: dvdmtw98/mkdocs-netlify-deploy@v1
        with:
          build_mode: manual
          main_repository: dvdmtw98/obsidian
          main_repo_checkout: development
          main_repo_access_token: ${{ secrets.ACCESS_TOKEN }}
          config_repository: dvdmtw98/mkdocs-config
          config_repo_access_token: ${{ secrets.ACCESS_TOKEN }}
          markdown_location: My Vault
          social_plugin_used: true
          netlify_auth_token: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          netlify_site_id: ${{ secrets.NETLIFY_SITE_ID }}
```