require 'spec_helper'

describe VoiceActorRole do
  it { should belong_to(:appearance) }
  it { should belong_to(:voice_actor) }

  it { should validate_numericality_of(:voice_actor_id).only_integer }
  it { should validate_presence_of(:appearance_id) }
  it { should validate_numericality_of(:appearance_id).only_integer }
end
