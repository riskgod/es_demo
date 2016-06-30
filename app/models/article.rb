require 'elasticsearch/model'

class Article < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

# settings index: { number_of_shards: 1 } do
#   mappings dynamic: 'false' do
#     indexes :title, analyzer: 'english', index_options: 'offsets'
#     indexes :text, analyzer: 'english'
#   end
# end

 def as_indexed_json(options={})
   self.as_json(
     only: [:id, :title, :text]
   )
 end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^10', 'text']
          }
        },
        highlight: {
          pre_tags: ['<em>'],
          post_tags: ['</em>'],
          fields: {
            title: {},
            text: {}
          }
        }
      }
    )
  end
end
Article.import