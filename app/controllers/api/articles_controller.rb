class Api::ArticlesController < ApplicationController
  def index
    sorting_hash = { where: {} }
    sorting_hash[:where][:user_id] = User.find_by!(email: params[:user_email]).id if params[:user_email].present?
    sorting_hash[:where][:category] = params[:category] if params[:category].present?
    sorting_hash[:sort_by] = params[:sort_by] if params[:sort_by].present?
    sorting_hash[:order] = params[:order] if params[:order].present?
    articles = Article.get_articles(**sorting_hash)

    render json: { articles: articles }, status: :ok
  rescue => e
    rescue_exceptions(e)
  end

  def show
    article = Article.find(params.require(:id))

    render json: {
      title: article.title,
      body: article.body,
      category: article.category,
      creator: article.creator.email,
      published_date: article.published_date,
      comments_count: article.comments.count
    }, status: :ok
  rescue => e
    rescue_exceptions(e)
  end

  def create
    article = @current_user.articles.create(create_params)
    render json: { article: article }, status: :created
  rescue => e
    rescue_exceptions(e)
  end

  def update
    Article.update(params.require(:id), update_params) && (render json: { article: article })
  rescue => e
    rescue_exceptions(e)
  end

  def destroy
    if @current_user.id == (article = Article.find(params.require(:id))).user_id
      article.destroy && (render json: { message: 'Article successfully deleted.' }, status: :ok)
    else
      render json: { error: 'Only author can delete this article.' }, status: :forbidden
    end
  rescue => e
    rescue_exceptions(e)
  end

  private

  def create_params
    params.require(:article).permit(:title, :body, :category, :published_date).tap { |create_params|
      create_params.require([:title, :body, :category])
    }
  end

  def update_params
    params.require(:article).permit(:title, :body, :category).tap { |update_params|
      update_params.require([:title, :body, :category])
    }
  end

  def rescue_exceptions(e)
    if e.is_a? ActiveRecord::RecordNotFound
      render json: { error: 'No record found with given id.' }, status: :not_found
    else
      render json: { error: "Something went wrong. See: #{e}" }, status: :internal_server_error
    end
  end
end
