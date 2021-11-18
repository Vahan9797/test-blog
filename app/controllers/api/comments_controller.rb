class Api::CommentsController < ApplicationController
  def index
    begin
      raise ActiveRecord::RecordNotFound if (article = Article.find_by(id: comment_params)).nil?

      render json: { comments: article.comments }, status: :ok
    rescue => e
      rescue_exceptions(e)
    end
  end
  
  def show
    begin
      article_id, id = *comment_params
      
      if (article = Article.find_by(id: article_id)).nil? || (comment = article.comments.where(id: id).first).nil?
        raise ActiveRecord::RecordNotFound
      end

      render json: { comment: comment }, status: :ok
    rescue => e
      rescue_exceptions(e)
    end
  end

  def create
    begin
      article_id, text = *comment_params
      raise ActiveRecord::RecordNotFound if (article = Article.find_by(id: article_id)).nil?

      comment = article.comments.create(
        text: text.last,
        user_id: @current_user.id
      )

      render json: { comment: comment }, status: :created
    rescue => e
      rescue_exceptions(e)
    end
  end

  def destroy
    begin
      article_id, id = *comment_params

      if (article = Article.find_by(id: article_id)).nil? || (comment = article.comments.where(id: id).first).nil?
        raise ActiveRecord::RecordNotFound
      end

      if comment.author.id != @current_user.id
        render json: { error: 'Only author can delete his comment.' }, status: :forbidden
      else
        comment.destroy && (render json: { message: 'Comment successfully deleted.' }, status: :ok)
      end
    rescue => e
      rescue_exceptions(e)
    end
  end

  private

  def comment_params
    case params[:action].to_sym
    when :index
      params.require(:article_id)
    when :show, :destroy
      p "PARAMS: #{params}"
      {
        article_id: params.require(:article_id),
        id: params.require(:id)
      }
    when :create
      {
        article_id: params.require(:article_id),
        text: params.require(:text)
      }
    end
  end

  def rescue_exceptions(e)
    if e.is_a? ActiveRecord::RecordNotFound
      render json: { error: 'No record found with given id.' }, status: :not_found
    else
      render json: { error: "Something went wrong. See: #{e}" }, status: :internal_server_error
    end
  end
end
