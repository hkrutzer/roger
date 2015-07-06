module Roger
  module Helpers
    # Shell helpers for modules
    module Shell
      # Ask the user a question they can answer with: y/Y/Yes
      # it will append [y/N] to the question
      #
      # @param [String] question The question to ask
      # @param [Boolean] default The default answer if you press enter
      def prompt_yes?(question, default = true)
        return true if project.options[:yes]
        return false if project.options[:no]

        choices = default == true ? "Y/n" : "y/N"
        answer = project.shell.ask("#{question} [#{choices}]")

        if answer =~ /\A(yes|y})\z/i
          true
        elsif answer == ""
          default
        else
         false
        end
      end
    end
  end
end
