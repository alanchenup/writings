class Dashboard::NotesController < Dashboard::BaseController
  def new
    @article = @space.articles.find_by :token => params[:article_id]
    @notes = @article.notes.where(:element_id => params[:element_id]).includes(:comments)
  end

  def create
    @article = @space.articles.find_by :token => params[:article_id]
    @note = @article.notes.new note_param.merge(:user => current_user, :workspace => @space)
    @note.save
  end

  private

  def note_param
    params.require(:note).permit(:body, :element_id)
  end
end
