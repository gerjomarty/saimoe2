(2002..2011).each do |year|
  t = Tournament.find_or_initialize_by_year year.to_s
  t.group_stages = case year
    when 2002
      [:round_1, :round_1_playoff, :round_2, :round_2_playoff, :round_3, :group_final]
    when 2003
      [:round_1, :round_1_playoff, :round_2, :round_3, :group_final]
    when 2004, 2010
      [:round_1, :round_2, :group_final]
    when 2005..2009, 2011
      [:round_1, :round_2, :round_3, :group_final]
    else
      raise "Year #{year} doesn't have stages defined"
  end
  finals = [:quarter_final, :semi_final, :final]
  finals.unshift :last_16 if year == 2002
  t.final_stages = finals
  t.save!
end