# install\_tmcstu

[中文说明](README.org)

This is a set of scripts to install basic tools for research purpose
on a new student PC (Fedora 30+) in the TMC group.

## Usage

The main driver scripts are `install_tmcstu.sh` and `install_repos_pkgs.sh`.

### `install_tmcstu.sh`

This script is used to initialize.
Basically, you only need to run with the subcommand `init`.

```bash
chmod +x install_tmcstu.sh
./install_tmcstu.sh init
```

This will install some tools from the Fedora repository by `using dnf`,
hence you may need to enter password for sudo.
If you are interested in trying CUDA, run

```bash
./install_tmcstu.sh cuda  # install cuda-kit
./install_tmcstu.sh vc    # verify the installation
```

Note that you may need to modify BIOS to make the CUDA card detected
when it is not directly connected to your display.

For more detailed instruction, see information from

```bash
./install_tmcstu.sh help
```

### `install_repos_pkgs.sh`

This script is used to install tools from website (i.e. external repositories) and softwares obtained from the TMC workstation.
Before installation, you should have the source at your disposal.
The external repositories and workstation pacakges can be downloaded by

```bash
./install_tmcstu.sh repo
./install_tmcstu.sh pkg
```

After this, you can find the source files in `repos` and `pkgs` directories.
Then you can run

```bash
./install_repos_pkgs.sh all
```

to install the repositories and pacakges that have corresponding installers.
Run

```bash
./install_repos_pkgs.sh list
```

to see available installers.

Note that you have to need to install by yourself if the pacakge has no available installer.
In this case, it would be great if you can help to implement the installer
in `extern_repos.sh` or `tmcws_pkgs.sh`.

## Customization

See `custom.sh`

## Extension

One may need to extend the list of online repositories to be downloaded,
or retrieve more packages from the TMC workstation.
To these ends, they can modify arrays in `extern_repos.sh` and `tmcws_pkgs.sh`, respectively.
See either file for more guidance.

