class MatchInfo
  GROUP_STAGES = %w{round_1 round_1_playoff round_2 round_2_playoff round_3 group_final losers_playoff_round_1 losers_playoff_round_2 losers_playoff_finals}.collect(&:to_sym).freeze
  FINAL_STAGES = %w{last_32 last_16 quarter_final semi_final final}.collect(&:to_sym).freeze
  PLAYOFF_STAGES = %w{round_1_playoff round_2_playoff losers_playoff_round_1 losers_playoff_round_2 losers_playoff_finals}.collect(&:to_sym).freeze
  PLAYOFF_GROUPS = %w{y z losers_playoff}.collect(&:to_sym).freeze
  STAGES = (GROUP_STAGES + FINAL_STAGES).freeze

  def self.pretty_stage stage
    case stage
    when :final then 'Grand Final'
    else             stage.to_s.gsub(/_/, ' ').titleize
    end
  end

  def self.pretty_group group, length=:long
    return '' unless group
    case length
    when :long
      if group.size == 1
        "Group #{group.upcase}"
      else
        group.to_s.gsub(/_/, ' ').titleize
      end
    when :short
      group.to_s.split('_').collect(&:first).join.upcase
    end
  end
end
