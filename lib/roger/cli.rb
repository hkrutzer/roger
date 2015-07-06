require "rubygems"

# Require bundler gems if available
Bundler.require(:default) if Object.const_defined?(:Bundler)

require "thor"
require "thor/group"

require "pathname"
require "fileutils"
include FileUtils

require File.dirname(__FILE__) + "/version"
require File.dirname(__FILE__) + "/template"
require File.dirname(__FILE__) + "/project"

module Roger
  # The CLI namespace
  module Cli; end
end

require File.dirname(__FILE__) + "/cli/command"
require File.dirname(__FILE__) + "/cli/serve"
require File.dirname(__FILE__) + "/cli/release"
require File.dirname(__FILE__) + "/cli/generate"
require File.dirname(__FILE__) + "/cli/test"

require File.dirname(__FILE__) + "/generators"
require File.dirname(__FILE__) + "/test"

module Roger
  # The Roger main entrypoint!
  class Cli::Base < Thor
    def initialize(*args)
      super
      self.class.project ||= initialize_project
    end

    class << self
      attr_accessor :project

      def exit_on_failure?
        true
      end
    end

    class_option :path,
                 desc: "Project root path",
                 type: :string,
                 required: false,
                 default: "."

    class_option :html_path,
                 desc: 'The document root, defaults to "[directory]/html"',
                 type: :string

    class_option :partial_path,
                 desc: "Defaults to [directory]/partials",
                 type: :string

    class_option :verbose,
                 desc: "Sets verbose output",
                 aliases: ["-v"],
                 default: false,
                 type: :boolean

    class_option :yes,
                 desc: "Answers all prompts with yes",
                 aliases: ["-y"],
                 default: false,
                 type: :boolean

    class_option :no,
                 desc: "Answers all prompts with no",
                 aliases: ["-n"],
                 default: false,
                 type: :boolean

    map %w(--version) => :version

    desc "test [COMMAND]", "Run one or more tests. Test can be 'all' for all
                            defined tests or a specific test name"
    subcommand "test", Cli::Test

    desc "generate [COMMAND]", "Run a generator"
    subcommand "generate", Cli::Generate

    register(
      Cli::Serve,
      "serve",
      "serve #{Cli::Serve.arguments.map(&:banner).join(' ')}",
      Cli::Serve.desc
    )
    tasks["serve"].options = Cli::Serve.class_options

    register(
      Cli::Release,
      "release",
      "release #{Cli::Release.arguments.map(&:banner).join(' ')}",
      Cli::Release.desc
    )
    tasks["release"].options = Cli::Release.class_options

    desc "version", "Get the current Roger version"
    def version
      shell.say "Roger #{Roger::VERSION}"
    end

    protected

    # TODO: handle options
    def initialize_project
      if (Pathname.new(options[:path]) + "../partials").exist?
        puts "[ERROR]: Don't use the \"html\" path, use the project base path instead"
        exit(1)
      end

      Project.new(options[:path], { shell: shell }.update(options))
    end
  end
end
