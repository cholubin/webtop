# encoding: utf-8
class FaqsController < ApplicationController
  # GET /faqs
  # GET /faqs.xml
  def index
    @faqs = Faq.all
    @menu = "board"
    @board = "faq"
    @section = "index"
    

    render 'faq' 
  end

  # GET /faqs/1
  # GET /faqs/1.xml
  def show
    @faq = Faq.get(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @faq }
    end
  end

end
