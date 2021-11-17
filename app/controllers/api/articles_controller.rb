class Api::ArticlesController < ApplicationController
  def index
    begin
      user_email, category, sort_by, order = *article_params(request_type: :index)

      raise ArgumentError.new('[sort_by] must be of String type.') if !sort_by.nil? && !sort_by.is_a? String
      raise ArgumentError.new('[order] must be of String type.') if !order.nil? && !order.is_a? String

      where_hash = {}
      where_hash[:user_id] = user.id if user_email.present? && !(user = User.find_by(email: user_email)).nil?
      where_hash[:category] = category if category.present?

      sort_by = 'created_at' unless ['title', 'body', 'category', 'published_date', 'created_at', 'updated_at'].include?(sort_by.downcase)
      order = 'desc' unless ['asc', 'desc'].include?(order.downcase)

      articles = Article.get_articles(where).order("#{sort_by} #{order}")

      render json: { articles: articles }, status: :ok        

      rescue => e
        if e.is_a? ArgumentError
          render json: { error: e.message } status: :not_found
        else
          render json: { error: "Something went wrong. See: #{e}" } status: :internal_server_error
        end
      end
  end

  def show
    begin
      article = Article.find_by(id: id)
      raise ActiveRecord::RecordNotFound if article.nil?

      render json: {
        title: article.title,
        body: article.body,
        category: article.category,
        creator: article.creator.email,
        published_date: article.published_date,
        comments_count: article.comments.count
      }
    rescue => e
      if e.is_a? ActiveRecord::RecordNotFound
        render json: { error: 'No record found with given id.' } , status: :not_found
      else
        render json: { error: "Something went wrong. See: #{e}" } status: :internal_server_error
      end
    end
  end

  def create
    begin
      title, body, category, published_date = *article_params(request_type: :create)
      article = Article.create!(
        title: title,
        body: body,
        category: category,
        published_date: published_date,
        user_id: current_user.id
      )
      render json: { article: article }
    rescue => e
      if e.is_a? ActiveRecord::RecordInvalid
        render json: { error: e.message }, status: :unprocessable_entity
      else
        render json: { error: "Something went wrong. See: #{e}" }, status: :internal_server_error
      end
    end
  end

  def update
    begin
      update_params = article_params(request_type: :update)
      raise ActiveRecord::RecordNotFound if (article = Article.find_by(id: update_params[:id])).nil?

      article.update!(update_params) && render json: { article: article }
    rescue => e
      if e.is_a? ActiveRecord::RecordNotFound
        render json: { error: 'No record found with given id.' }, status: :not_found
      else
        render json: { error: "Something went wrong. See: #{e}" }, status: :internal_server_error
      end
    end
  end

  def destroy
    begin
      id = *article_params(request_type: :destroy)
      raise ActiveRecord::RecordNotFound if (article = Article.find_by(id: id)).nil?
      if current_user.id == article.user_id
        article.destroy && render json: { message: 'Article successfully deleted.' }, status: :ok
      else
        render json: { error: 'Only author can delete this article.' }, status: :forbidden
      end
    rescue => e
      if e.is_a? ActiveRecord::RecordNotFound
        render json: { error: 'No record found with given id.' }, status: :not_found
      else
        render json: { error: "Something went wrong. See: #{e}" }, status: :internal_server_error
      end
    end
  end

  private

  def article_params(request_type: :index)
    case request_type
    when :index
      params.permit(:user_email, :category, :sort_by, :order)
    when :show
      params.permit(:id)
    when :create
      params.permit(:title, :body, :category, :published_date)
    when :update
      params.permit(:id, :title, :body, :category)
    when :destroy
      params.permit(:id)
    end
  end
end
