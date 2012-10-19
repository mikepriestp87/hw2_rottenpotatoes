class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

   def hash_to_querystring(hash)
    hash.keys.inject('') do |query_string, key|
      query_string << '&' unless key == hash.keys.first
      query_string << "ratings[#{URI.encode(key.to_s)}]=#{URI.encode(hash[key])}"
    end
  end

  def index
    @sort = params[:sort]
    @ratings = params[:ratings]

    #set local var with choice or all
    if @ratings.nil?
      
      if !session[:ratings].nil?
        #redirect for session
        #session.destroy
       redirect_to request.fullpath + "?" + hash_to_querystring(session[:ratings])
       
      end
      
      chosen_ratings = Movie.ratings
      
    else
      chosen_ratings = @ratings.keys
      session[:ratings] = @ratings

    end
    
   
    #loop all ratings and set users opted
    @all_ratings = Hash.new
    Movie.ratings.each do |rating| 
         @all_ratings[rating] = chosen_ratings.include?(rating)
    end

    if !@sort.nil?
      begin
        #use find_all_by local ratings
        @movies = Movie.order("#{@sort} ASC").find_all_by_rating(chosen_ratings)
      rescue ActiveRecord::StatementInvalid
        flash[:warning] = "Movies can't be sorted by #{@sort}."
        @movies = Movie.find_all_by_rating(chosen_ratings)
      end
    else
      @movies = Movie.find_all_by_rating(chosen_ratings)
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
