# encoding: utf-8

class Admin::FreeboardsController < ApplicationController
  layout "admin_layout"
  before_filter :authenticate_admin!      
  # GET /freeboards
  # GET /freeboards.xml
  def index
    @menu = "board"
    @board = "freeboard"
    @section = "index"
      
    @freeboard = Freeboard.search(params[:search], params[:page])
    @total_count = Freeboard.search(params[:search],"").count
      
    render 'admin/freeboards/freeboard'
  end

  # GET /freeboards/1
  # GET /freeboards/1.xml
  def show
    @freeboard = Freeboard.get(params[:id])
    
    if @freeboard
    
      @freeboard.hit_cnt += 1
      @freeboard.save
    
      @menu = "board"
      @board = "freeboard"
      @section = "show"
      
      render 'freeboard'
    
    else
      redirect_to '/freeboards'
    end

  end



  # DELETE /freeboards/1
  # DELETE /freeboards/1.xml
  def destroy
    @freeboard = Freeboard.get(params[:id])
    
    # session check
    if signed_in? && @freeboard.user_id == current_user.id
      @freeboard.destroy
    end

    respond_to do |format|
      format.html { redirect_to(admin_freeboards_url) }
      format.xml  { head :ok }
    end
  end
  
  
  # multiple deletion
  def deleteSelection 

    chk = params[:chk]

    if !chk.nil? 
      chk.each do |chk|
        @freeboard = Freeboard.get(chk[0].to_i)
        @freeboard.destroy    
      end
    else
        flash[:notice] = '삭제할 글을 선택하지 않으셨습니다!'    
    end
      
    redirect_to(admin_freeboards_url)  
   end
  
end
