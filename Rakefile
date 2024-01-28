# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[spec rubocop]

desc 'Generate RBS'
task :generate_rbs do
  require 'active_support/testing/stream'
  require 'orthoses'
  require_relative 'lib/openapi_rails_typed_parameters'

  namespace = OpenapiRailsTypedParameters.to_s

  out = Pathname(__FILE__).dirname / 'sig/generated'

  begin
    out.rmtree
  rescue StandardError
    nil
  end

  Orthoses.logger.level = :warn
  Orthoses::Builder.new do
    use Orthoses::CreateFileByName,
        to: 'sig/generated',
        rmtree: true,
        header: '# Generated code'
    use Orthoses::Filter do |name, _content|
      name.start_with?(namespace)
    end
    use Orthoses::Mixin
    use Orthoses::Constant
    use Orthoses::Trace,
        patterns: [namespace, "#{namespace}::*"]
    use Orthoses::RBSPrototypeRB,
        paths: Dir.glob('lib/**/*.rb')
    run lambda {
      _ = OpenapiRailsTypedParameters::VERSION
      Class.new.extend(ActiveSupport::Testing::Stream).instance_exec do
        silence_stream($stdout) do
          require 'rspec'
          spec_files = Dir.glob('spec/**/*_spec.rb')
          RSpec::Core::Runner.run(spec_files)
        end
      end
    }
  end.call
end
