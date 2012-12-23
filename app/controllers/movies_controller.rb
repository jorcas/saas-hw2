class MoviesController < ApplicationController
  def initialize
    super
    @all_ratings = {'G'=>true, 'PG'=>true, 'PG-13'=>true, 'R'=>true}
  end

  def show
    if params.include?(:sort)
      if params.include?(:ratings)
        ratings_h = Hash.new
        params[:ratings].each do |key,v| 
          if params[:ratings][key]=='true'; ratings_h[key] = '1' end
        end
      else
        ratings_h = @all_ratings
      end
      # will render app/views/movies/?sort=mode
      redirect_to movies_path(:sort=>params[:sort], :ratings=>ratings_h)
    else
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  end

  def index
    if session.include?(:ratings)
      @all_ratings = session[:ratings]
    end
    logger.debug('ratings-1:')
    logger.debug(@all_ratings)

    @title_class = 'normal'
    @release_class = 'normal'
    if params.include?(:ratings)
      rating_list = params[:ratings].keys
    else
      rating_list = @all_ratings.keys
    end
    @all_ratings.each {|key,v| @all_ratings[key] = false }
    rating_filter = ''
    add_or_txt = false
    rating_list.each do |rating|
      if add_or_txt; rating_filter << ' or ' end
      rating_filter << 'rating=' + '\'' + rating + '\''
      add_or_txt = true
      @all_ratings[rating] = true
    end
    session[:ratings] = @all_ratings
    logger.debug('ratings-2:')
    logger.debug(@all_ratings)
    if params.include?(:sort)
      @movies = Movie.find(:all, :order=> params[:sort], :conditions =>rating_filter)
      if params[:sort] == 'title' 
        @title_class = 'hilite'
      elsif params[:sort] == 'release_date' 
        @release_class = 'hilite'
      end
    else
      @movies = Movie.find(:all, :conditions =>rating_filter)
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

