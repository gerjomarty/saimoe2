require 'spec_helper'

describe CharacterRole do
  it { should belong_to(:character) }
  it { should belong_to(:series) }
  it { should have_many(:appearances) }

  it { should validate_presence_of(:character_id) }
  it { should validate_numericality_of(:character_id) }
  it { should validate_presence_of(:series_id) }
  it { should validate_numericality_of(:series_id) }
end
