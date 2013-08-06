##
#General Support Functions
##


def multiple_of?(number)
  self % number == 0
end

def even?
  multiple_of? 2
end

def odd?
  !even?
end