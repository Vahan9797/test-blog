class Article < ApplicationRecord
  belongs_to :creator, class_name: 'User', inverse_of: :articles
  has_many :comments, inverse_of: :article, dependent: :destroy

  validates :title, presence: true, limit: { minimum: 1, maximum: 100 }, allow_nil: false

  def self.get_articles(where: {})
    begin
      articles = where.empty? ? Article.all : Article.where(where)
      articles.joins(:comments).select("substring(body for 500) || '...' AS body, title, published_date" +
        ", (SELECT COUNT(comments.*) FROM comments WHERE comments.article_id = article.id) AS comments_count"
      )
    rescue => e
      raise e
    end
  end
end
