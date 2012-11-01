class MoviesController < ApplicationController
  def show
    if params.include?(:sort)
      # will render app/views/movies/?sort=mode
      redirect_to movies_path(:sort=>params[:sort])
    else
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  end

  def index
    @title_class = 'normal'
    @release_class = 'normal'
    if params.include?(:sort)
      @movies = Movie.find(:all, :order=> params[:sort])
      if params[:sort] == 'title' 
        @title_class = 'hilite'
      elsif params[:sort] == 'release_date' 
        @release_class = 'hilite'
      end
    else
      @movies = Movie.all
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
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
