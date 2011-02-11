# encoding: utf-8
class Admin::FaqsController < ApplicationController
    layout "admin_layout"
    before_filter :authenticate_admin!    
    
  # GET /adminfaqs
  # GET /adminfaqs.xml
  def index
    @faqs = Faq.all.search(params[:search], params[:page])  
    @total_count = Faq.search(params[:search],"").count
    
    @menu = "board"
    @board = "faq"
    @section = "index"

    render 'faq'  
  end

  # GET /adminfaqs/1
  # GET /adminfaqs/1.xml
  def show
    @menu = "board"
    @board = "faq"
    @section = "show"
    
    @faq = Faq.get(params[:id].to_i)

    render 'faq'  
  end

  # GET /adminfaqs/new
  # GET /adminfaqs/new.xml
  def new
    
    @menu = "board"
    @board = "faq"
    @section = "new"
    
    @faq = Faq.new

    render 'faq'  
  end

  # GET /adminfaqs/1/edit
  def edit
    @menu = "board"
    @board = "faq"
    @section = "edit"
        
    @faq = Faq.get(params[:id].to_i)
    
     render 'faq'  
  end

  # POST /adminfaqs
  # POST /adminfaqs.xml
  def create
    @faq = Faq.new(params[:faq])

    if @faq.save
      redirect_to admin_faqs_url
    else
      @section = "new" 
      render 'faq'
    end
    
  end

  # PUT /adminfaqs/1
  # PUT /adminfaqs/1.xml
  def update
    @menu = "board"
    @board = "faq"
    @section = "index"
        
    @faq = Faq.get(params[:faq][:id].to_i)
    
    @faq.question = params[:faq][:question]
    @faq.answer = params[:faq][:answer]
    
    @faqs = Faq.all.search(params[:search], params[:page])  
    @total_count = Faq.search(params[:search],"").count
    
    if @faq.save
      render 'faq'      
    end
  end

  def destroy
    @faq = Faq.get(params[:id].to_i)
    @faq.destroy

    respond_to do |format|
      format.html { redirect_to(admin_faqs_url) }
      format.xml  { head :ok }
    end
  end
  
  # multiple deletion
  def deleteSelection 

    chk = params[:chk]

    if !chk.nil? 
      chk.each do |chk|
        @faq = Faq.get(chk[0].to_i)
        @faq.destroy    
      end
    else
        flash[:notice] = '삭제할 글을 선택하지 않으셨습니다!'    
    end
      
    redirect_to(admin_faqs_url)  
   end
  
end
