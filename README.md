<div align="center">

# asdf-vagrant [![Build](https://github.com/igno/asdf-vagrant/actions/workflows/build.yml/badge.svg)](https://github.com/igno/asdf-vagrant/actions/workflows/build.yml) [![Lint](https://github.com/igno/asdf-vagrant/actions/workflows/lint.yml/badge.svg)](https://github.com/igno/asdf-vagrant/actions/workflows/lint.yml)

[vagrant](https://developer.hashicorp.com/vagrant) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

## Linux
- FUSE (libfuse.so.2), see [AppImage docs](https://github.com/AppImage/AppImageKit/wiki/FUSE).
- `bash`, `curl`, `unzip`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add vagrant
# or
asdf plugin add vagrant https://github.com/igno/asdf-vagrant.git
```

vagrant:

```shell
# Show all installable versions
asdf list-all vagrant

# Install specific version
asdf install vagrant latest

# Set a version globally (on your ~/.tool-versions file)
asdf global vagrant latest

# Now vagrant commands are available
vagrant --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/igno/asdf-vagrant/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Erik Jutemar](https://github.com/igno/)
