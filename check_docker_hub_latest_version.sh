name: Version Compare

on:
  workflow_dispatch:

jobs:
  compare-versions:
    runs-on: ubuntu-latest

    steps:
    - name: Clone Source Repository
      run: |
        git clone https://activitypub.software/TransFem-org/Sharkey.git
        cd Sharkey

    - name: Extract Version from package.json
      id: extract_version
      run: |
        cd Sharkey
        remote_version=$(jq -r '.version' package.json)
        echo "remote_version=$remote_version" >> $GITHUB_ENV
        echo "Extracted remote version: $remote_version"

    - name: Get Docker Latest Version
      run: |
        curl -o check_docker_hub_latest_version.sh \
          https://raw.githubusercontent.com/Akuma-real/sharkey-dev-docker/refs/heads/master/check_docker_hub_latest_version.sh
        chmod +x check_docker_hub_latest_version.sh
        latest_version=$(./check_docker_hub_latest_version.sh)
        echo "docker_version=$latest_version" >> $GITHUB_ENV
        echo "Extracted Docker version: $latest_version"

    - name: Compare Versions
      run: |
        echo "Remote package.json version: ${{ env.remote_version }}"
        echo "Docker latest version: ${{ env.docker_version }}"
        if [ "${{ env.remote_version }}" != "${{ env.docker_version }}" ]; then
          echo "版本不同，需要更新。"
        else
          echo "版本相同，无需更新。"
        fi
