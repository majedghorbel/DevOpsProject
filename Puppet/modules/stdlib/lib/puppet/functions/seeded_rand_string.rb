# frozen_string_literal: true

# THIS FILE WAS GENERATED BY `rake regenerate_unamespaced_shims`

# @summary DEPRECATED.  Use the namespaced function [`stdlib::seeded_rand_string`](#stdlibseeded_rand_string) instead.
Puppet::Functions.create_function(:seeded_rand_string) do
  dispatch :deprecation_gen do
    repeated_param 'Any', :args
  end
  def deprecation_gen(*args)
    call_function('deprecation', 'seeded_rand_string', 'This function is deprecated, please use stdlib::seeded_rand_string instead.', false)
    call_function('stdlib::seeded_rand_string', *args)
  end
end