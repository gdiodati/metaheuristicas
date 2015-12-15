# $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/.."))
require_relative '../node'


def assert_not_equal(expected, actual, message = nil)
  assert expected != actual, message
end

def deny(condition, message = "Expected condition to be unsatisfied")
  assert !condition, message
end
