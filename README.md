# install\_tmcstu

[中文说明](README.org)

This is a set of scripts to install basic tools for research purpose
on a new student PC (Fedora 30+) in the TMC group.

## Usage

The main driver scripts are `install_tmcstu` and `install_repos_pkgs`.

### `install_tmcstu`

This script is used to initialize and install components by using system package manager.
Basically, you only need to run with the subcommand `init`.

```bash
chmod +x install_tmcstu
./install_tmcstu init
```

This will install some tools from the Fedora repository by `using dnf`,
hence you may need to enter password for sudo.
If you are interested in trying CUDA, run

```bash
./install_tmcstu cuda  # install cuda-kit
./install_tmcstu vc    # verify the installation
```

Note that you may need to modify BIOS to make the CUDA card detected
when it is not directly connected to your display.

For more detailed instruction, see information from

```bash
./install_tmcstu help
```

### `install_repos_pkgs`

This script is used to dowload and install tools from website (i.e. external repositories)
and softwares obtained from the remote server.
You can run

```bash
./install_repos_pkgs min
```

to install the basic (minimal) repositories and pacakges. Run

```bash
./install_repos_pkgs list
```

to see all available installers, and run

```bash
./install_repos_pkgs name
```

To install a certain repo or package "name" as listed

Note that you have to need to install by yourself if the pacakge has no available installer.
In this case, it would be great if you can help to implement the installer
in `extern_repos.sh` or `remote_pkgs.sh`.

Note that you may not have to the sources when you run the installer,
because it will automatically detect and download from website or retrive from remote server
if necessary.
Alternatively, source files can be downloaded before-hand by subcommand `dl`, e.g.

```bash
./install_repos_pkgs dl repos # only online repositories
./install_repos_pkgs dl pkgs  # only packages on remote server
./install_repos_pkgs dl all   # both repositories and packages
./install_repos_pkgs dl name  # a certain package "name"
```

After then you can find source files in `repos` and `pkgs` directories.

## Customization

See `custom.sh`

- `PREFIX`: target directory to install the repos and packages by `install_repos_pkgs`

Also remember to change `SSH_CONNECTION` in `remote_pkgs.sh` and make the connection
password free, when you need to retrieve package from the remote server.

## Extension

One may need to extend the list of online repositories to be downloaded,
or retrieve more packages from the TMC workstation.
To these ends, they can modify arrays in `extern_repos.sh` and `remote_pkgs.sh`, respectively.
See either file for more guidance.

