class Api::CommentsController < ApplicationController
  def index
    begin
      render json: { comments: Article.find(params.require(:article_id)).comments }, status: :ok
    rescue => e
      render json: { error: "Something went wrong. See: #{e}" }
    end
  end
  
  def show
    begin
      render json: {
        comment: Article.find(params.require(:article_id)).comments.where(id: params.require(:id)).first
      }, status: :ok
    rescue => e
      render json: { error: "Something went wrong. See: #{e}" }
    end
  end

  def create
    begin
      comment = Article.find(params.require(:article_id)).comments.create(
        text: params.require(:text),
        user_id: @current_user.id
      )

      render json: { comment: comment }, status: :created
    rescue => e
      render json: { error: "Something went wrong. See: #{e}" }
    end
  end

  def destroy
    begin
      comment = Article.find(params.require(:article_id)).comments.where(id: params.require(:id)).first
      
      if comment.author.id != @current_user.id
        render json: { error: 'Only author can delete his comment.' }, status: :forbidden
      else
        comment.destroy && (render json: { message: 'Comment successfully deleted.' }, status: :ok)
      end
    rescue => e
      render json: { error: "Something went wrong. See: #{e}" }
    end
  end
end
