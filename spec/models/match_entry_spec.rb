require 'spec_helper'

describe MatchEntry do
  it { should belong_to(:match) }
  it { should belong_to(:previous_match) }
  it { should belong_to(:appearance) }

  it { should validate_presence_of(:position) }
  it { should validate_numericality_of(:position) }
  it { should validate_numericality_of(:number_of_votes) }
  it { should validate_presence_of(:match_id) }
  it { should validate_numericality_of(:match_id) }
  it { should validate_numericality_of(:previous_match_id) }
  it { should validate_numericality_of(:appearance_id) }
end
