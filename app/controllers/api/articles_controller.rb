class Api::ArticlesController < ApplicationController
  def index
    begin
      user_email, category, sort_by, order = index_params
      
      articles = Article.get_articles(
        sort_by: sort_by,
        order: order,
        where: {
          user_email: user_email,
          category: category
        }
      )

      render json: { articles: articles }, status: :ok        
    rescue => e
      render json: { error: "Something went wrong. See: #{e}" }
    end
  end

  def show
    begin
      article = Article.find(id: params[:id])

      render json: {
        title: article.title,
        body: article.body,
        category: article.category,
        creator: article.creator.email,
        published_date: article.published_date,
        comments_count: article.comments.count
      }, status: :ok
    rescue => e
      if e.is_a? ActiveRecord::RecordNotFound
        render json: { error: 'No record found with given id.' }, status: :not_found
      else
        render json: { error: "Something went wrong. See: #{e}" }, status: :internal_server_error
      end
    end
  end

  def create
    begin
      article = @current_user.articles.create(create_params)
      render json: { article: article }, status: :created
    rescue => e
      render json: { error: "Something went wrong. See: #{e}" }
    end
  end

  def update
    begin
      Article.update(params.require(:id), update_params) && (render json: { article: article })
    rescue => e
      render json: { error: "Something went wrong. See: #{e}" }
    end
  end

  def destroy
    if (article = Article.find_by(id: article_params)).nil?
      render json: { error: 'No record found with given id.' }, status: :not_found
    end

    if @current_user.id == article.user_id
      article.destroy && (render json: { message: 'Article successfully deleted.' }, status: :ok)
    else
      render json: { error: 'Only author can delete this article.' }, status: :forbidden
    end
  end

  private

  def index_params
    params.require(:articles).permit(:user_email, :category, :sort_by, :order).tap { |index_params|
      index_params.require([:user_email, :category, :sort_by, :order])
    }
  end

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
end
