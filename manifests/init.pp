# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include neovim
class neovim (
  String[1] $user = 'tongue',
  String[1] $group = 'tongue',
) {
  package { ['git', 'cmake', 'ninja-build', 'gettext', 'curl', 'build-essential']:
    ensure => present,
  }
  -> package { 'vim':
    ensure => absent,
  }
  -> file { ['/usr/bin/vi', '/usr/bin/vim.tiny', '/usr/bin/vimtutor']:
    ensure => absent,
  }
  -> file { "/home/${user}/.config":
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }
  -> vcsrepo { "/home/${user}/.config/neovim":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/neovim/neovim.git',
    owner    => $user,
    group    => $group,
    require  => Package['git'],
  }
  -> exec { 'compile_neovim':
    command => 'make CMAKE_BUILD_TYPE=RelWithDebInfo',
    cwd     => "/home/${user}/.config/neovim",
    user    => $user,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Vcsrepo["/home/${user}/.config/neovim"],
  }
  -> exec { 'install_neovim':
    command => 'sudo make install',
    cwd     => "/home/${user}/.config/neovim",
    user    => $user,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Exec['compile_neovim'],
  }
  -> exec { 'clean workstation':
    command => 'rm -rf puppet7-release-jammy.deb neovim',
    cwd     => "/home/${user}/",
    user    => $user,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Exec['compile_neovim', 'install_neovim'],
  }
}
