require 'rhcl'

local_default_filename = 'locals.tf'
@local_defaults = Rhcl.parse(File.open(local_default_filename))
