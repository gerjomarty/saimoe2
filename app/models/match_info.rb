class MatchInfo
  GROUP_STAGES = %w{round_1 round_1_playoff round_2 round_2_playoff round_3 group_final}.collect(&:to_sym).freeze
  FINAL_STAGES = %w{last_16 quarter_final semi_final final}.collect(&:to_sym).freeze
  PLAYOFF_STAGES = %w{round_1_playoff round_2_playoff}.collect(&:to_sym).freeze
  PLAYOFF_GROUPS = %w{y z}.collect(&:to_sym).freeze
  STAGES = (GROUP_STAGES + FINAL_STAGES).freeze
end