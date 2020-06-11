# frozen_string_literal: true

module Docxgen
  module Templates
    class Parser
      VARIABLE_REGEX = /({{[[:space:]]?(([[:alpha:]]|_)+([[:alnum:]]|_|\.)*(?<!\.))[[:space:]]?}})/

      def self.tr_substitute!(tr, data, strict: true)
        found_variables = self.find_variables(tr)

        errors = []

        found_variables.each do |var|
          value = data.dig(*var[:path])

          errors.push("No value provided for variable: #{var[:src]}") if value.nil?

          next if value.nil? && strict # Don't replace variables with nil's in strict mode

          tr.substitute(var[:src], value)
        end

        [tr, errors]
      end

      def self.find_variables(tr)
        tr.to_s.scan(VARIABLE_REGEX).map do |match|
          src, path, *_ = match

          {
            src: src,
            path: path.split(".").reject(&:empty?).map do |p|
              Integer(p) rescue next p.to_sym

              p.to_i
            end
          }
        end
      end
    end
  end
end
