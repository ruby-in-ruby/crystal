module Ast
  class IfExpression < Expression
#    attr_reader  :cond, :if_true, :if_false
    def compile frame , method
      is = cond.compile(frame , method)
      #      is.is_false(frame,method)
      # TODO should/will use different branches for different conditions. 
      branch = Virtual::ImplicitBranch.new "if_merge"
      method.add branch
      last = is
      if_true.each do |part|
        last = part.compile(frame,method )
        raise part.inspect if last.nil?
      end
      merge = Virtual::Label.new(branch.name)
      method.add merge
      branch.swap
      method.current = branch
      if_false.each do |part|
        last = part.compile(frame,method )
        raise part.inspect if last.nil?
      end
      method.add merge
      branch.swap
      method.current = merge
      #TODO should return the union of the true and false types
      last
    end
    def old
      f = context.function
      # to execute the logic as the if states it, the blocks are the other way around
      # so we can the jump over the else if true ,and the else joins unconditionally after the true_block
      merge_block = f.new_block "if_merge"
      true_block = f.new_block "if_true"
      false_block = f.new_block "if_false"

      puts "compiling if condition #{cond}"
      cond_val = cond.compile(context)
      unless cond_val.is_a? Virtual::BranchCondition
        cond_val = cond_val.is_true? f
      end
      f.b true_block , condition_code: cond_val.operator
      f.insertion_point.branch = true_block

      f.insert_at false_block
      if_false.each do |part|
        puts "compiling in if false #{part}"
        last = part.compile(context  )
      end
      f.b merge_block
      f.insertion_point.branch = false_block

      f.insert_at true_block
      last = nil
      if_true.each do |part|
        puts "compiling in if true #{part}"
        last = part.compile(context )
      end

      puts "compiled if: end"
      f.insert_at merge_block

      return last
    end
  end
end