require 'spec_helper'

describe MatchEntry do
  it { should belong_to(:match) }
  it { should belong_to(:previous_match) }
  it { should belong_to(:appearance) }

  it { should validate_presence_of(:position) }
  it { should validate_numericality_of(:position).only_integer }
  it { should validate_presence_of(:match_id) }
end
