class LandbResponse

  def initialize(hash)
    hash.each do |k,v|
      next if k.to_s =~ /@|:/
      
      if v.instance_of? Hash
        self.instance_variable_set("@#{k}", LandbResponse.new(v))  ## create and initialize an instance variable for this hash.
      elsif v.instance_of? Array
        v_array = v.collect do |new_v| 
          if (new_v.instance_of? Array) || (new_v.instance_of? Hash)
            LandbResponse.new(new_v) 
          else
            new_v
          end
        end

        self.instance_variable_set("@#{k}", v_array)  ## create and initialize an instance variable based on an array.
      else
        self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair.
      end
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable        
    end
  end
  
  def get_values_for_paths paths_array
    responses = []
    
    paths_array.each do |path|
      responses << get_value_for_path(path)
    end
    
    responses
  end
  
  def get_value_for_path path_array
    response_runner = self
    
    path_array.each do |domain|
      response_runner = response_runner.send domain.to_sym
    end
    
    response_runner
  end
end