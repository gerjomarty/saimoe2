require 'spec_helper'

describe CharacterRole do
  it { should belong_to(:character) }
  it { should belong_to(:series) }
  it { should have_many(:appearances) }

  it { should validate_presence_of(:character_id) }
  it { should validate_presence_of(:series_id) }
  it { should validate_presence_of(:role_type) }
  it { should allow_value(:major).for(:role_type) }
  it { should allow_value(:cameo).for(:role_type) }
  it { should_not allow_value(:blah).for(:role_type) }
end
