# frozen_string_literal: true

require 'spec_helper'

describe 'neovim' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      context 'with default parameters' do
        let(:facts) { os_facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('Install nodeJS for COC') }
        it { is_expected.to contain_exec('Install nvim Plugin') }
        it { is_expected.to contain_exec('clean workstation') }
        it { is_expected.to contain_exec('compile_neovim') }
        it { is_expected.to contain_exec('install_coc_dependencies') }
        it { is_expected.to contain_exec('install_neovim') }
        it { is_expected.to contain_exec('install_vim_plug') }

        it { is_expected.to contain_file('/home/tongue/.config/nvim') }
        it { is_expected.to contain_file('/home/tongue/.config') }
        it { is_expected.to contain_file('/opt') }

        it { is_expected.to contain_package('build-essential') }
        it { is_expected.to contain_package('cmake') }
        it { is_expected.to contain_package('curl') }
        it { is_expected.to contain_package('gettext') }
        it { is_expected.to contain_package('git') }
        it { is_expected.to contain_package('ninja-build') }

        it { is_expected.to contain_vcsrepo('/home/tongue/.config/neovimconf') }
        it { is_expected.to contain_vcsrepo('/opt/neovim') }

      end

      context 'with custom parameters' do
        let(:facts) { os_facts }
        let(:params) { { delete_vim: true, user: 'test' } }

        it { is_expected.to contain_package('vim').with_ensure('absent') }
        [
          '/usr/bin/vi',
          '/usr/bin/vim.tiny',
          '/usr/bin/vimtutor',
          '/home/test/.vim'
        ].each do |path|
          it { is_expected.to contain_file(path).with_ensure('absent') }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_exec('Install nodeJS for COC') }
        it { is_expected.to contain_exec('Install nvim Plugin') }
        it { is_expected.to contain_exec('clean workstation') }
        it { is_expected.to contain_exec('compile_neovim') }
        it { is_expected.to contain_exec('install_coc_dependencies') }
        it { is_expected.to contain_exec('install_neovim') }
        it { is_expected.to contain_exec('install_vim_plug') }

        it { is_expected.to contain_file('/home/test/.config/nvim') }
        it { is_expected.to contain_file('/home/test/.config') }
        it { is_expected.to contain_file('/opt') }

        it { is_expected.to contain_package('build-essential') }
        it { is_expected.to contain_package('cmake') }
        it { is_expected.to contain_package('curl') }
        it { is_expected.to contain_package('gettext') }
        it { is_expected.to contain_package('git') }
        it { is_expected.to contain_package('ninja-build') }

        it { is_expected.to contain_vcsrepo('/home/test/.config/neovimconf') }
        it { is_expected.to contain_vcsrepo('/opt/neovim') }
      end
    end
  end
end
