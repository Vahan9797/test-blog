class Article < ApplicationRecord
  belongs_to :creator, class_name: 'User', inverse_of: :articles
  has_many :comments, inverse_of: :article, dependent: :destroy

  validates :title, length: { minimum: 1, maximum: 100 }, on: [:create, :update], allow_nil: false

  after_create :check_published_date

  def self.get_articles(where: {}, sort_by: 'created_at', order: 'desc')
    begin
      articles = where.empty? ? Article.all : Article.where(where)
      articles.joins(:comments).select("substring(body for 500) || '...' AS body, title, published_date" +
        ", (SELECT COUNT(comments.*) FROM comments WHERE comments.article_id = articles.id) AS comments_count"
      ).order("articles.#{sort_by} #{order}")
    rescue => e
      raise e
    end
  end

  private

  def check_published_date
    self.published_date = self.created_at if self.published_date.nil?
  end
end
