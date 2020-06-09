# frozen_string_literal: true

module Docxgen
  module Templates
    class Parser
      VARIABLE_REGEX = /({{[[:space:]]?(([[:alpha:]]|_)+([[:alnum:]]|_|\.)*(?<!\.))[[:space:]]?}})/

      def self.tr_substitute!(tr, data)
        found_variables = self.find_variables(tr)
      end

      def self.find_variables(tr)
        tr.to_s.scan(VARIABLE_REGEX).map do |match|
          src, path, *_ = match

          {
            src: src,
            path: path.split(".").reject(&:empty?)
          }
        end
      end

      def self.dig_key_path(path, data)
        data.dig(*path)
      end
    end
  end
end
