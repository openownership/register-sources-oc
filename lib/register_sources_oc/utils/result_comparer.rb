module RegisterSourcesOc
  module Utils
    class ResultComparer
      def compare_results(results)
        match_failures = []

        results.each do |service1, response1|
          results.each do |service2, response2|
            next unless service1 < service2
            next unless response1 != response2

            incorrect1 = get_non_matching_fields(response1, response2)
            incorrect2 = get_non_matching_fields(response2, response1)

            next if incorrect1.empty? && incorrect2.empty?

            match_failures << {
              service1:,
              response1: incorrect1,
              service2:,
              response2: incorrect2,
            }
          end
        end

        match_failures
      end

      private

      def get_non_matching_fields(response1, response2)
        if response1.is_a?(Array) != response2.is_a?(Array)
          response1
        elsif response1.is_a?(Array)
          if response1.empty?
            {}
          elsif response2.empty?
            response1[0][:company]
          else
            get_non_matching_fields(response1[0][:company], response2[0][:company])
          end
        else
          response1.keys.map do |k|
            next if k == :registered_address_country
            next if response1[k] == response2[k]

            if k == :registered_address_in_full && (response1[k].strip == response2[k].strip)
              next
            end

            [k, response1[k]]
          end.compact.to_h
        end
      end
    end
  end
end
