module NoticesHelper

    def entitle(notice)
      notice.title.length > 90 ? notice.title[0,89]+" ...": notice.title
    end

    def entitle_main(notice)
      notice.title.length > 45 ? notice.title[0,47]+" ...": notice.title
    end

  
end
