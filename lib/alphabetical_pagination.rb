class AlphabeticalPagination
  attr_accessor :no_of_columns, :relation, :secondary_method, :letter_method, :default_letter

  # Returns array of size columns (or fewer, if less data) with {letter => objects} hashes
  # (will return array of {letter => {secondary_model => objects}} instead if secondary_method is not nil)
  def get_data
    check_variables
    @data ||= calculate_letter_hash

    if @no_of_columns <= 1 || @data.keys.size <= 1
      return [@data]
    elsif @no_of_columns >= @data.keys.size
      return @data.collect {|l,v| {l => v}}
    end

    @entities ||= calculate_individual_entities
    @dividing_letters ||= get_dividing_letters

    (@range_arguments ||= get_range_arguments).collect do |first, second|
      if first == second
        @data.select {|l,_| l == first}
      elsif first == @default_letter
        range = second == 'Z' ? ('A'..second) : ('A'...second)
        @data.select {|l,_| ([@default_letter] + range.to_a).compact.include?(l)}
      else
        range = second == 'Z' ? (first..second) : (first...second)
        @data.select {|l,_| range.to_a.include?(l)}
      end
    end # Return array of hashes
  end

  def real_no_of_columns
    if @no_of_columns <= 1 || @data.keys.size <= 1
      1
    elsif @no_of_columns >= @data.keys.size
      @data.keys.size
    else
      @range_arguments.size
    end
  end

  def active_letters
    @data && @data.reject {|_,v| v.empty?}.keys
  end

  def no_of_columns= value
    clear_variables if @no_of_columns != value
    @no_of_columns = value
  end

  def relation= value
    clear_variables if @relation != value
    @relation = value
  end

  def secondary_method= value
    clear_variables if @secondary_method != value
    @secondary_method = value
  end

  def letter_method= value
    clear_variables if @letter_method != value
    @letter_method = value
  end

  def default_letter= value
    clear_variables if @default_letter != value
    @default_letter = value
  end

  private

  def check_variables
    raise "no_of_columns must be defined" unless @no_of_columns
    raise "relation must be defined" unless @relation
    raise "secondary_method must be a Proc" unless (@secondary_method.nil? || @secondary_method.is_a?(Proc))
    raise "letter_method must be a Proc" unless @letter_method && @letter_method.is_a?(Proc)
    raise "default_letter must be a String" unless (@default_letter.nil? || @default_letter.is_a?(String))
  end

  def clear_variables
    @data = nil
    @entities = nil
    @dividing_letters = nil
    @range_arguments = nil
  end

  def calculate_individual_entities
    entities = @data.values.flatten
    entities = entities.collect(&:to_a).flatten if @secondary_method
    entities
  end

  def calculate_letter_hash
    {}.tap { |ent|
      ([@default_letter] + ('A'..'Z').to_a).compact.each {|l| ent[l] = @secondary_method ? {} : [] }

      @relation.each do |rel|
        letter_string = @letter_method.call(rel)
        raise "letter_method must return a String" unless letter_string.is_a?(String)
        letter = letter_string[0].capitalize
        letter = @default_letter unless @default_letter.nil? || letter =~ /[A-Z]/
        if @secondary_method
          secondary_model = @secondary_method.call(rel)
          ent[letter][secondary_model] ||= []
          ent[letter][secondary_model] << rel
        else
          ent[letter] << rel
        end
      end
    }.delete_if {|_,v| v.empty?}
  end

  def get_dividing_letters
    (1...@no_of_columns).collect { |col|
      ent = @entities[(@entities.size * col.to_f / @no_of_columns.to_f).to_i]
      letter = @data.select { |l,v|
        v.is_a?(Array) ? v.include?(ent) : ((v.has_key?(ent)) || v.values.flatten.include?(ent))
      }.keys[0]
    }.uniq
  end

  def get_range_arguments
    [[@default_letter || 'A', @dividing_letters.first]] +
        @dividing_letters.each_cons(2).to_a +
        [[@dividing_letters.last, 'Z']]
  end
end
