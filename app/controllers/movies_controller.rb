class MoviesController < ApplicationController
  def initialize
    super
    @all_ratings = {'G'=>true, 'PG'=>true, 'PG-13'=>true, 'R'=>true}
  end

  def show
    logger.debug "** show **"
    if params.include?(:sort) or params.include?(:ratings)
      if params.include?(:ratings)
        ratings_h = Hash.new
        params[:ratings].each do |key,v| 
          if params[:ratings][key]=='true'; ratings_h[key] = '1' end
        end
      else
        ratings_h = @all_ratings
      end
      if params.include?(:sort)
        sort_h = params[:sort]
      else
        sort_h = {:sort=>'none'}
      end
      # will render app/views/movies/ + session set
      redirect_to movies_path(:sort=>sort_h, :ratings=>ratings_h)
    else
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  end

  def index
    logger.debug "** index **"
    use_redirect = false

    @title_class = 'normal'
    @release_class = 'normal'
    if params.include?(:ratings)
      rating_list = params[:ratings].keys
    elsif session.include?(:ratings)
      logger.debug "** session have ratings"
      rating_list = session[:ratings].reject{|k,v| v == false}.keys
      use_redirect = true
    else
      rating_list = @all_ratings.keys
    end
    logger.debug "** rating list: #{rating_list}"
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
    logger.debug "** ratings: #{@all_ratings}"

    sort = 'none'
    if params.include?(:sort)
      sort = params[:sort]
    elsif session.include?(:sort)
      sort = session[:sort]
      use_redirect = true
    end
    session[:sort] = sort
    logger.debug "** sorting: #{sort}"
    if use_redirect
      redirect_to movies_path(:sort=>sort, :ratings=>@all_ratings.reject{|k,v| v == false}) and return
    end

    if sort != 'none'
      @movies = Movie.find(:all, :order=>sort, :conditions=>rating_filter)
      if sort == 'title' 
        @title_class = 'hilite'
      elsif sort == 'release_date' 
        @release_class = 'hilite'
      end
    else
      @movies = Movie.find(:all, :conditions=>rating_filter)
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

