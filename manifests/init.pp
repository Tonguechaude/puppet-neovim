# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @param user     User account name
# @param group    User account group name
# @param keepvim  Boolean value to let the user the choice to keep vim installed
#
# @example
#   include neovim
class neovim (
  String[1] $user = 'tongue',
  String[1] $group = 'tongue',

  Boolean   $delete_vim = false,
) {
  package { ['git', 'cmake', 'ninja-build', 'gettext', 'curl', 'build-essential']:
    ensure => present,
  }
  if $delete_vim {
    package { 'vim':
      ensure => absent,
    }
    -> file { ['/usr/bin/vi', '/usr/bin/vim.tiny', '/usr/bin/vimtutor', "/home/${user}/.vim"]:
      ensure => absent,
    }
  }
  file { "/home/${user}/.config":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0700',
  }
  file { '/opt':
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }
  -> vcsrepo { '/opt/neovim':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/neovim/neovim.git',
    owner    => $user,
    group    => $group,
    require  => Package['git'],
  }
  -> exec { 'compile_neovim':
    command => 'make CMAKE_BUILD_TYPE=RelWithDebInfo',
    cwd     => '/opt/neovim',
    user    => $user,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Vcsrepo['/opt/neovim'],
  }
  -> exec { 'install_neovim':
    command => 'sudo make install',
    cwd     => '/opt/neovim',
    user    => $user,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin',
    require => Exec['compile_neovim'],
  }
  -> vcsrepo { "/home/${user}/.config/neovimconf":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/Tonguechaude/neovim.git',
    owner    => $user,
    group    => $group,
    require  => Package['git'],
  }
  -> file { "/home/${user}/.config/nvim":
    ensure  => directory,
    links   => follow,
    source  => "/home/${user}/.config/neovimconf/nvim",
    recurse => true,
    owner   => $user,
    group   => $group,
  }
  -> exec { 'Install nodeJS for COC':
    command     => "bash -c \"export HOME=/home/${user} && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash && source /home/${user}/.nvm/nvm.sh && nvm install 22\"",
    cwd         => "/home/${user}/",
    user        => $user,
    path        => '/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin',
    environment => ["HOME=/home/${user}"],
  }
  -> exec { 'install_vim_plug':
    command => "curl -fLo /home/${user}/.local/share/nvim/site/autoload/plug.vim --create-dirs \
              https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
    creates => "/home/${user}/.local/share/nvim/site/autoload/plug.vim",
    user    => $user,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin',
  }
  -> exec { 'Install nvim Plugin':
    command => 'nvim --headless +PlugInstall +qall',
    cwd     => "/home/${user}/",
    user    => $user,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin',
  }
  exec { 'install_coc_dependencies':
    command => 'npm install',
    cwd     => "/home/${user}/.config/nvim/bundle/coc.nvim",
    user    => $user,
    path    => "/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin:/home/${user}/.nvm/versions/node/v22.14.0/bin",
    creates => "/home/${user}/.config/nvim/bundle/coc.nvim/build/index.js",
  }
  -> exec { 'clean workstation':
    command => 'rm -rf puppet7-release-jammy.deb /opt/neovim',
    cwd     => "/home/${user}/",
    user    => $user,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Exec['compile_neovim', 'install_neovim'],
  }
}
