require_relative "instruction"
require_relative "register_value"
require_relative "assembler"

# So the memory model of the machine allows for indexed access into an "object" .
# A fixed number of objects exist (ie garbage collection is reclaming, not destroying and
#  recreating) although there may be a way to increase that number.
