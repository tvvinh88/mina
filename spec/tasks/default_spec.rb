# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'default', type: :rake do
  before do
    load_default_config
  end

  describe 'environment' do
    it 'outputs a deprecation warning' do
      expect { invoke_all }.to output(output_file('environment')).to_stdout
    end
  end

  describe 'ssh_keyscan_repo' do
    it 'scans ssh' do
      Mina::Configuration.instance.set(:repository, 'git@github.com/exapmle')
      expect { invoke_all }.to output(output_file('ssh_keyscan_repo')).to_stdout
    end
  end

  describe 'ssh_keyscan_domain' do
    let(:task_name) { 'ssh_keyscan_domain' }

    context "when domain isn't set" do
      before do
        Mina::Configuration.instance.remove(:domain)
      end

      it 'exits with an error message' do
        expect do
          invoke_all
        end.to raise_error(SystemExit)
           .and output(/domain must be defined!/).to_stdout
      end
    end

    context "when port isn't set" do
      before do
        Mina::Configuration.instance.remove(:port)
      end

      it 'exits with an error message' do
        expect do
          invoke_all
        end.to raise_error(SystemExit)
           .and output(/port must be defined!/).to_stdout
      end
    end

    context 'when conditions are met' do
      it 'scans ssh' do
        expect do
          invoke_all
        end.to output(output_file('ssh_keyscan_domain')).to_stdout
      end
    end
  end

  describe 'run' do
    it 'runs command' do
      task.invoke('ls -al')
      expect { run_commands.invoke }.to output(output_file('run')).to_stdout
    end

    it 'exits if no command given' do
      expect { task.invoke }.to raise_error(SystemExit)
                               .and output(/You need to provide a command/).to_stdout
    end
  end

  describe 'ssh' do
    it 'opens an SSH connection when :deploy_to exists' do
      expect do
        invoke_all
      end.to change { Mina::Configuration.instance.fetch(:execution_mode) }.to(:exec)
         .and output(output_file('ssh')).to_stdout
    end

    it "exits with an error message when :deploy_to isn't set" do
      Mina::Configuration.instance.remove(:deploy_to)

      expect do
        invoke_all
      end.to raise_error(SystemExit)
         .and output(/deploy_to must be defined!/).to_stdout
    end
  end

  describe 'debug_configuration_variables' do
    before do
      Mina::Configuration.instance.set(:debug_configuration_variables, true)
      ENV['keep_releases'] = '1234'
    end

    after do
      Mina::Configuration.instance.remove(:debug_configuration_variables)
      ENV.delete('keep_releases')
    end

    it 'prints configuration variables' do
      expect do
        invoke_all
      end.to output(output_file('debug_configuration_variables')).to_stdout
    end
  end
end
