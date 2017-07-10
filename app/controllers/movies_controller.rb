class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def process_ratings_parameters
    if params[:ratings].nil?
      if session[:selected_ratings].nil?
        session[:selected_ratings] = @all_ratings.map { |r| [r, '1'] }.to_h
      else
        @selected_ratings = session[:selected_ratings].keys
      end
      @query_parameters[:ratings] = session[:selected_ratings]
      @redirect = true
    else
      @selected_ratings = params[:ratings].keys
      session[:selected_ratings] = params[:ratings]
      @query_parameters[:ratings] = session[:selected_ratings]
    end
  end

  def process_sort_paremeter
    if params[:sort_by] == 'title'
      @sort_by = :title
      session[:sort_by] = @sort_by
    elsif params[:sort_by] == 'release_date'
      @sort_by = :release_date     
      session[:sort_by] = @sort_by
    elsif not session[:sort_by].nil?
      @query_parameters[:sort_by] = session[:sort_by]
      @redirect = true
    end
  end


  def index

    @query_parameters = {}
    @all_ratings = Movie.all_ratings

    process_ratings_parameters
    process_sort_paremeter

    @movies = Movie.where(rating: @selected_ratings)
    
    if not @redirect.nil?
      flash.keep
      redirect_to movies_path(@query_parameters)
    end

    if not @sort_by.nil?
      @movies.order!("#{@sort_by} ASC")
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
