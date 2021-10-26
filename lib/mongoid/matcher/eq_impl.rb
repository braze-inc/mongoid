module Mongoid
  module Matcher

    # This module is used by $eq and other operators that need to perform
    # the matching that $eq performs (for example, $ne which negates the result
    # of $eq). Unlike $eq this module takes an original operator as an
    # additional argument to +matches?+ to provide the correct exception
    # messages reflecting the operator that was first invoked.
    #
    # @api private
    module EqImpl
      module_function def matches?(exists, value, condition, original_operator)
        case condition
        when Range
          # Since $ne invokes $eq, the exception message needs to handle
          # both operators.
          raise Errors::InvalidQuery, "Range is not supported as an argument to '#{original_operator}'"
=begin
          if value.is_a?(Array)
            value.any? { |elt| condition.include?(elt) }
          else
            condition.include?(value)
          end
=end
        else
          if value.kind_of?(Time) && condition.kind_of?(Time)
            time_eq?(value, condition)
          else
            value == condition ||
            value.is_a?(Array) && value.include?(condition)
          end
        end
      end

      # Per https://docs.mongodb.com/ruby-driver/current/tutorials/bson-v4/#time-instances,
      # > Times in BSON (and MongoDB) can only have millisecond precision. When Ruby Time instances
      # are serialized to BSON or Extended JSON, the times are floored to the nearest millisecond.
      #
      # > Because of this flooring, applications are strongly recommended to perform all time
      # calculations using integer math, as inexactness of floating point calculations may produce
      # unexpected results.
      #
      # As such, perform a similar operation to what the bson-ruby gem does
      module_function def time_eq?(time_a, time_b)
        time_a_millis = time_a._bson_to_i * 1000 + time_a.usec.divmod(1000).first
        time_b_millis = time_b._bson_to_i * 1000 + time_b.usec.divmod(1000).first
        time_a_millis == time_b_millis
      end
    end
  end
end
