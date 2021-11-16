class Api::ArticlesController < ApplicationController
  def index
    user_id, category, sorting_by, order = *article_params(request_type: :index)
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
        render json: { error: e.message }
      else
        render json: { error: "Something went wrong. See: #{e}" }
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
        render json: { error: 'No record found with given id.' }
      else
        render json: { error: "Something went wrong. See: #{e}" }
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
        render json: { error: 'No record found with given id.' }
      else
        render json: { error: "Something went wrong. See: #{e}" }
      end
    end
  end

  private

  def article_params(request_type: :index)
    case request_type
    when :index
      params.permit(:user_id, :category, :sort_by, :order)
    when :create
      params.permit(:title, :body, :category, :published_date)
    when :update
      params.permit(:id, :title, :body, :category)
    when :destroy
      params.permit(:id)
    end
  end
end
