#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/hashicorp/vagrant"
TOOL_NAME="vagrant"
TOOL_TEST="vagrant --help"
SUPPORTED_OS="GNU/Linux"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if vagrant is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

verify() {
	local -r version="$1"
	local -r file="$2"
	local -r checksum_path="${ASDF_DOWNLOAD_PATH}/vagrant_${version}_SHA256SUMS"
	local -r gpg_path="${ASDF_DOWNLOAD_PATH}/vagrant_${version}_SHA256SUMS.sig"

	gpg --import <(curl "${curl_opts[@]}" https://keybase.io/hashicorp/pgp_keys.asc)

	checksum_url="https://releases.hashicorp.com/vagrant/${version}/vagrant_${version}_SHA256SUMS"

	if ! curl -fs "${checksum_url}" -o "${checksum_path}"; then
		echo "couldn't download checksum file" >&2
	fi

	gpg_url="https://releases.hashicorp.com/vagrant/${version}/vagrant_${version}_SHA256SUMS.sig"
	if ! curl -fs "$gpg_url" -o "${gpg_path}"; then
		echo "couldn't download gpg signature file" >&2
	fi

	if ! gpg --verify "${gpg_path}" "${checksum_path}"; then
		echo "gpg verification failed" >&2
		return 1
	fi
	shasum_command="shasum -a 256"
	if ! command -v shasum &>/dev/null; then
		shasum_command=sha256sum
	fi
	if ! (cd "${ASDF_DOWNLOAD_PATH}" && ${shasum_command} -c <(grep "$(basename $file)" "${checksum_path}")); then
		echo "checksum verification failed" >&2
		return 2
	fi
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
	curl "${curl_opts[@]}" https://releases.hashicorp.com/vagrant/ | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"
}

check_os() {
	if [ "$(uname -o)" != "$SUPPORTED_OS" ]; then
		fail "This plugin is only supported on $SUPPORTED_OS"
	fi
}

release_file_name() {
	local version="$1"
	echo "vagrant_${version}_linux_amd64.zip"
}

download_release() {
	check_os
	local version filename url
	version="$1"
	filename="$2"
	url="https://releases.hashicorp.com/vagrant/${version}/vagrant_${version}_linux_amd64.zip"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"

	verify "$version" "$filename" || fail "Download verification failed"
}

install_version() {
	check_os
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" "$install_path/$TOOL_NAME"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
