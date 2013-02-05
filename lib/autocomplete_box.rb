class AutocompleteBox
  include ActionView::Helpers::FormTagHelper

  attr_reader :source_path, :placeholder_text

  def initialize source_path, placeholder_text=nil
    @source_path = source_path
    @placeholder_text = placeholder_text
  end

  def render
    text_field_tag 'autocomplete_name', nil,
                   class: 'search-query',
                   style: 'display: none;',
                   data: {source_path: @source_path},
                   placeholder: @placeholder_text
  end
end
