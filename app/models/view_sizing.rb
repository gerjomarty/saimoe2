class ViewSizing
  PADDING = 0.2
  BORDER_THICKNESS = 0.1
  BORDER_RADIUS = 0.3

  # CharacterEntry

  CE_PADDING = PADDING
  CE_BORDER_THICKNESS = BORDER_THICKNESS
  CE_BORDER_RADIUS = BORDER_RADIUS

  CE_IMAGE_WIDTH = 3.077
  CE_IMAGE_HEIGHT = CE_IMAGE_WIDTH

  CE_VOTES_WIDTH = CE_IMAGE_WIDTH - CE_PADDING
  CE_VOTES_HEIGHT = CE_VOTES_WIDTH

  CE_FIXED_WIDTH = 18
  CE_FIXED_WIDTH_WITHOUT_AVATAR = CE_FIXED_WIDTH - CE_IMAGE_WIDTH - CE_PADDING

  CE_FIXED_OUTER_WIDTH = CE_FIXED_WIDTH + 2 * CE_BORDER_THICKNESS + 2 * CE_PADDING
  CE_OUTER_HEIGHT = CE_IMAGE_HEIGHT + 2 * CE_BORDER_THICKNESS + 2 * CE_PADDING

  # MatchViewModel

  MVM_PADDING = PADDING
  MVM_BORDER_THICKNESS = BORDER_THICKNESS
  MVM_BORDER_RADIUS = BORDER_RADIUS

  MVM_INFO_WIDTH = CE_VOTES_WIDTH

  MVM_OUTER_WIDTH = CE_FIXED_OUTER_WIDTH + MVM_INFO_WIDTH + 2 * MVM_BORDER_THICKNESS + 2 * MVM_PADDING

  def self.mvm_outer_height entrant_counts
    entrant_counts = Array(entrant_counts)
    return 0 if entrant_counts.empty?

    entrant_counts.collect do |count|
      count * CE_OUTER_HEIGHT + 2 * MVM_BORDER_THICKNESS + 2 * MVM_PADDING
    end.reduce(:+)

    # height = entrant_counts.collect do |count|
    #   count * CE_OUTER_HEIGHT + 2 * MVM_BORDER_THICKNESS + 2 * MVM_PADDING
    # end.reduce(:+)
  end

  # We use top/bottom margins to place each MatchViewModels properly on the tournament page
  def self.match_tournament_margin match_entrant_count, base_entrant_counts
    (self.mvm_outer_height(base_entrant_counts) - self.mvm_outer_height(match_entrant_count) -
      ([base_entrant_counts.size - 3, 0].max) * MVM_BORDER_THICKNESS) / 2.0
  end

  # FinalMatchesViewModel

  FMVM_MARGIN = 0.4
  # This assumes the standard 4 QFs with 2 characters in each.
  # Padding is the height of a match view model with two entries.
  FMVM_SEMI_FINAL_TOP_PADDING = CE_OUTER_HEIGHT + 2 * MVM_BORDER_THICKNESS + 2 * MVM_PADDING

  FMVM_OUTER_WIDTH = 4 * (MVM_OUTER_WIDTH + 2 * FMVM_MARGIN) - FMVM_MARGIN

  # GroupMatchesViewModel

  GMVM_OUTER_WIDTH = FMVM_OUTER_WIDTH

  # GroupViewModel

  GVM_MARGIN = FMVM_MARGIN

end