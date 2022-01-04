class TagsController < ApplicationController
    def index
        @filter = params["filter"]
        @tags = @filter? Tag.where("name LIKE ?", "%#{@filter}%") : Tag.all
        render json: json_response("success", @tags)
    end

    def create
        @tag = Tag.new(tag_params)
        if @tag.save
            render json: json_response("success", @tag)
        else
            render json: json_response("error", @tag.errors)
        end
    end

    def destroy
        # find_by() returns nil if nothing found. find() raises an exception.
        @tag = Tag.find_by(id: params[:id])
        if !@tag
            render json: json_response("error", "Tag does not exist.")
        elsif @tag.taggings_count == 0
            @tag.destroy
            render json: json_response("success")
        else
            render json: json_response("error", "Cannot delete the tag.")
        end
    end
    
    #
    # Nested endpoints
    #
    def article_tags
        @article = Article.find_by(id: params[:article_id])
        render json_response("success", @article.tags)
    end

    def attach_tag
        @article = Article.find_by(id: params[:article_id])
        @tag = Tag.find(params[:tag_id])
        if @tag
            @article.tags << @tag
            render json: json_response("success", @article.tags)
        else
            render json: json_response("error", "Tag does not exist.")
        end
    end

    def detach_tag
        @article = Article.find_by(id: params[:article_id])
        @target_tag_id = params[:id].to_i   # Convert params[:id] from String to Integer
        @article.tags.each do |tag|
            if tag.id == @target_tag_id
                @article.tags.delete(tag)
            end
        end
        render json: json_response("success", @article.tags)
    end

    def retreive_articles
        @tag = Tag.find_by(id: params[:tag_id])
        render json: json_response("success", @tag.articles)
    end

    private
        def tag_params
            params.permit(:name)
        end

        def json_response(status, message="")
            {
                "status" => status,
                "message" => message
            }
        end
end
