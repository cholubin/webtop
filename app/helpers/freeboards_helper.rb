module FreeboardsHelper
  
  def entitle(freeboard)
    freeboard.title.length > 90 ? freeboard.title[0,89]+" ...": freeboard.title
  end
  
  def entitle_main(freeboard)
    freeboard.title.length > 45 ? freeboard.title[0,47]+" ...": freeboard.title
  end
end
