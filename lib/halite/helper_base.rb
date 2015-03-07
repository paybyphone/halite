#
# Copyright 2015, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Much inspiration from Bundler's GemHelper. Thanks!
require 'bundler'
require 'thor/shell'

require 'halite/error'

module Halite
  # Base class for helpers like Rake tasks.
  #
  # @since 1.0.0
  class HelperBase
    # Class method helper to install the tasks.
    #
    # @param args Arguments to be passed to {#initialize}.
    # @return [void]
    # @example
    #   MyApp::RakeHelper.install(gem_name: 'otherapp')
    def self.install(*args)
      new(*args).install
    end

    # @!attribute [r] gem_name
    # Name of the gem to use in these Rake tasks.
    # @return [String]
    attr_reader :gem_name
    # @!attribute [r] base
    # Base folder of the gem.
    # @return [String]
    attr_reader :base
    # @!attribute [r] options
    # Helper options.
    # @return [Hash<Symbol, Object>]
    attr_reader :options

    # @param gem_name [String] Name of the gem to use in these Rake tasks.
    # @param base [String] Base folder of the gem.
    # @options options [Boolean] no_color Forcibly disable using colors in the output.
    def initialize(gem_name: nil, base: nil, **options)
      @base = base || if defined?(::Rake) && ::Rake.original_dir
        ::Rake.original_dir
      else
        Dir.pwd
      end
      @gem_name = gem_name || find_gem_name(@base)
      @options = options
    end

    # Subclass hoook to provide the actual tasks or other helpers to install.
    #
    # @return [void]
    # @example
    #   def install
    #     extend Rake::DSL
    #     desc 'My awesome task'
    #     task 'mytask' do
    #       # ...
    #     end
    #   end
    def install
      raise NotImplementedError
    end

    private

    # Return a Thor::Shell object based on output settings.
    #
    # @return [Thor::Shell::Basic]
    # @example
    #   shell.say('Operation completed', :green)
    def shell
      @shell ||= if options[:no_color] || !STDOUT.tty?
        Thor::Shell::Basic
      else
        Thor::Base.shell
      end.new
    end

    # Search a directory for a .gemspec file to determine the gem name.
    # Returns nil if no gemspec is found.
    #
    # @param base [String] Folder to search.
    # @return [String, nil]
    def find_gem_name(base)
      spec = Dir[File.join(base, '*.gemspec')].first
      File.basename(spec, '.gemspec') if spec
    end

    # Specification for the current gem.
    #
    # @return [Gem::Specification]
    def gemspec
      @gemspec ||= begin
        raise Error.new("Unable to automatically determine gem name from specs in #{base}. Please set the gem name via #{self.class.name}.install_tasks(gem_name: 'name')") unless gem_name
        Bundler.load_gemspec(File.join(base, gem_name+'.gemspec'))
      end
    end
  end
end